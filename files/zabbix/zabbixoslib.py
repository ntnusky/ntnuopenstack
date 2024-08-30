#!/usr/bin/python3
import ipaddress
import MySQLdb
import MySQLdb.cursors
import re

ospattern = re.compile(r'('\
  r'Ubuntu\ (Server\ )?[0-9]{2}.[0-9]{2}|' \
  r'CentOS\ [0-9]"(\.[0-9])?|' \
  r'Windows\ (Server\ )?[0-9]+|' \
  r'Debian\ [0-9]+|' \
  r'Kali|' \
  r'AlmaLinux\ [0-9](\.[0-9])?|'\
  r'Rocky\ Linux\ [0-9](\.[0-9])?'\
  r')'
)

def glance_metrics(host, username, password):
  data = {}
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='glance')

  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT id, name, size, visibility FROM images WHERE deleted = 0")
  data['images'] = {
    x['id']: {
      'name': x['name'], 
      'id': x['id'], 
      'size': x['size'],
      'visibility': x['visibility'],
    } for x in c.fetchall()}

  c.close()
  db.close()

  data['size'] = 0
  data['no_images'] = 0
  data['visibilities'] = {}
  
  for i in data['images']:
    if not data['images'][i]['size']:
      data['images'][i]['size'] = 0

    data['size'] += data['images'][i]['size']
    data['no_images'] += 1

    try:
      data['visibilities'][data['images'][i]['visibility']]['size'] += \
        data['images'][i]['size']
      data['visibilities'][data['images'][i]['visibility']]['no_images'] += 1 
    except KeyError:
      data['visibilities'][data['images'][i]['visibility']] = {
        'name': data['images'][i]['visibility'],
        'size': data['images'][i]['size'],
        'no_images': 1
      }

  return data

def keystone_metrics(host, username, password):
  data = {}  
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='keystone')
  
  # Get the Domain ID
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT id FROM project WHERE is_domain = 1 AND name = 'NTNU'")
  domain_id = c.fetchone()['id']
  
  # Get the project-list
  c.execute("SELECT id, name FROM project WHERE is_domain = 0 AND domain_id = %s",
    (domain_id,))
  data['projects'] = {x['id']: x['name'] for x in c.fetchall()}
  
  # Add summaries
  data['no_projects'] = len(data['projects'])

  c.close()
  db.close()
  return data

def magnum_metrics(host, username, password):
  data = {'clusters': {}}
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='magnum')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  
  # Collect cluster templates 
  c.execute("SELECT uuid, name, hidden FROM cluster_template WHERE public = 1")
  data['templates'] = {
    x['uuid']: {
      'name': x['name'], 
      'uuid': x['uuid'],
      'hidden': x['hidden'], 
      'clusters': 0
    } for x in c.fetchall()
  }

  data['health_status'] = {}
  data['status'] = {}

  # Collect clusters
  c.execute("SELECT uuid, name, cluster_template_id, status, health_status FROM cluster")
  for cluster in c.fetchall():
    data['clusters'][cluster['uuid']] = cluster
    data['templates'][cluster['cluster_template_id']]['clusters'] += 1

    # Add do summary
    for v in ['health_status', 'status']:
      try:
        data[v][cluster[v]]['value'] += 1
      except KeyError:
        data[v][cluster[v]] = {
          'value': 1,
          'name': cluster[v],
        }
        
  return data

def neutron_metrics(host, username, password):
  data = {
    'external_networks': {},
  }
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='neutron')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c2 = db.cursor(MySQLdb.cursors.DictCursor)
  c3 = db.cursor(MySQLdb.cursors.DictCursor)

  # Get external networks
  c.execute("SELECT network_id, id, name, status FROM externalnetworks " \
    "INNER JOIN networks ON externalnetworks.network_id = networks.id")
  for network in c.fetchall():
    # Basic data about the network
    summary = {
      'ipv4_addresses': 0,
      'ipv4_used': 0,
      'ipv6_addresses': 0,
      'ipv6_used': 0,
    }
    data['external_networks'][network['name']] = {
      'id': network['id'],
      'name': network['name'],
      'status': network['status'],
      'subnets': {},
      'summary': summary,
    }

    # Subnets associated to the network
    c2.execute("SELECT id, name, cidr FROM subnets " \
      "WHERE network_id = %s", (network['id'],))
    for subnet in c2.fetchall():
      net = ipaddress.ip_network(subnet['cidr'])
      sn = { 
        'id': subnet['id'],
        'cidr': subnet['cidr'],
        'name': subnet['name'],
        'size': net.num_addresses,
        'allocatable': 0,
        'free': 0,
        'used': 0,
      }
      
      # Determine which addresses are allocatable from the subnet
      c3.execute("SELECT first_ip, last_ip FROM ipallocationpools " \
        "WHERE subnet_id = '%s'" % (sn['id'],))
      for allocation in c3.fetchall():
        first = ipaddress.ip_address(allocation['first_ip'])
        last = ipaddress.ip_address(allocation['last_ip'])
        for s in ipaddress.summarize_address_range(first, last):
          sn['allocatable'] += s.num_addresses

      c3.execute("SELECT COUNT(ip_address) FROM ipallocations " \
        "WHERE subnet_id = '%s'" % (sn['id'],))
      sn['used'] = c3.fetchone()['COUNT(ip_address)']
      sn['free'] = sn['allocatable'] - sn['used']

      data['external_networks'][network['name']]['subnets'][subnet['id']] = sn

      summary['ipv%d_addresses' % net.version] += sn['allocatable']
      summary['ipv%d_used' % net.version] += sn['used']

  # Get router statistics
  c.execute("SELECT host, COUNT(host) FROM routerl3agentbindings " \
    "INNER JOIN agents ON routerl3agentbindings.l3_agent_id = agents.id " \
    "GROUP BY host")
  data['network_agents'] = { 
    x['host']: { 'routers': x['COUNT(host)'], 'hostname': x['host']} for x in c.fetchall()
  }
  c.execute("SELECT COUNT(id) FROM routers")
  data['no_routers'] = c.fetchone()['COUNT(id)']

  # Get DHCP-agent statistics:
  c.execute("SELECT host, COUNT(host) FROM networkdhcpagentbindings " \
    "INNER JOIN agents ON networkdhcpagentbindings.dhcp_agent_id = agents.id " \
    "GROUP BY host")
  for agent in c.fetchall():
    try:
      data['network_agents'][agent['host']]['dhcp_agents'] = agent['COUNT(host)']
    except KeyError:
      data['network_agents'][agent['host']] = {'dhcp_agents': agent['COUNT(host)']}

  # Get L2-identifiers usage
  keys = ['free', 'allocated']
  data['ml2_l2ids'] = {}

  c.execute("SELECT allocated, COUNT(allocated) AS c "\
    "FROM ml2_vxlan_allocations GROUP BY allocated")
  for v in c.fetchall():
    try:
      data['ml2_l2ids']['VXLAN'][keys[v['allocated']]] = v['c']
    except KeyError:
      data['ml2_l2ids']['VXLAN'] = {
        'type': 'VXLAN',
        keys[v['allocated']]: v['c'],
      }

  c.execute("SELECT allocated, COUNT(allocated) AS c "\
    "FROM ml2_vlan_allocations GROUP BY allocated")
  for v in c.fetchall():
    try:
      data['ml2_l2ids']['VLAN'][keys[v['allocated']]] = v['c']
    except KeyError:
      data['ml2_l2ids']['VLAN'] = {
        'type': 'VLAN',
        keys[v['allocated']]: v['c'],
      }

  # Get subnet-pool statistics
  data['subnet_pools'] = {}
  c.execute("SELECT subnetpool_id, cidr, name FROM subnetpoolprefixes " \
    "INNER JOIN subnetpools ON subnetpools.id = subnetpoolprefixes.subnetpool_id")
  for pool in c.fetchall():
    try:
      data['subnet_pools'][pool['subnetpool_id']]['prefixes'].append(
        pool['cidr'])
    except KeyError:
      data['subnet_pools'][pool['subnetpool_id']] = {
        'prefixes': [pool['cidr']],
        'uuid': pool['subnetpool_id'],
        'name': pool['name'],
        'size': 0,
        'used': 0,
      }

    net = ipaddress.ip_network(pool['cidr'])
    # For IPv4 treat 'size' as number of addresses
    if net.version == 4:
      data['subnet_pools'][pool['subnetpool_id']]['size'] += net.num_addresses
    # For IPv6 treat 'size' as number of /64's
    else:
      data['subnet_pools'][pool['subnetpool_id']]['size'] += \
        2 ** (64 - net.prefixlen)

  c.execute("SELECT cidr, subnetpool_id FROM subnets WHERE subnetpool_id")
  for allocation in c.fetchall():
    net = ipaddress.ip_network(allocation['cidr'])
    if net.version == 4:
      data['subnet_pools'][allocation['subnetpool_id']]['used'] += \
        net.num_addresses
    else:
      data['subnet_pools'][allocation['subnetpool_id']]['used'] += \
        2 ** (64 - net.prefixlen)

  return data

def nova_metrics(host, username, password):
  data = {} 
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='nova')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  
  # Get instances
  c.execute("SELECT vm_state, memory_mb, vcpus, host, root_gb, ephemeral_gb," \
    "image_ref FROM instances where deleted = 0")

  data['vm_total'] = {
    'memory_mb': 0,
    'vcpus': 0,
    'vms': 0,
    'root_gb': 0,
    'ephemeral_gb': 0,
  }
  data['vmstates'] = {}
  data['images'] = {}

  for row in c.fetchall():
    for f in data['vm_total']:
      if f == 'vms':
        data['vm_total'][f] += 1
      else:
        data['vm_total'][f] += row[f]

    if(len(row['image_ref'])):
      try:
        data['images'][row['image_ref']] += 1
      except KeyError:
        data['images'][row['image_ref']] = 1

    try:
      data['vmstates'][row['vm_state']]['value'] += 1
    except KeyError:
      data['vmstates'][row['vm_state']] = {
        'value': 1,
        'name': row['vm_state'],
      }

  c.execute("SELECT hypervisor_hostname, running_vms, vcpus, memory_mb, " \
    "vcpus_used, memory_mb_used, local_gb, local_gb_used " \
    "FROM compute_nodes WHERE deleted = 0")
  data['hypervisors'] = {x['hypervisor_hostname']: x for x in c.fetchall()}

  data['no_hypervisors'] = len(data['hypervisors'])

  data['hypervisor_totals'] = {
    'memory_mb': 0,
    'vcpus': 0,
  }
  for h in data['hypervisors']:
    for v in data['hypervisor_totals']:
      data['hypervisor_totals'][v] += data['hypervisors'][h][v]

  c.close()
  db.close()
  return data

def octavia_metrics(host, username, password):
  data = {}  
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='octavia')
  
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("select id, name, provisioning_status, operating_status, topology from load_balancer")
  data['loadbalancers'] = {x['id']: {
      'id': x['id'],
      'name': x['name'],
      'provisioning_status': x['provisioning_status'],
      'operating_status': x['operating_status'],
      'topology': x['topology'],
    } for x in c.fetchall()
  }

  data['amphora_statuses'] = {}
  c.execute("SELECT status FROM amphora")
  for r in c.fetchall():
    try:
      data['amphora_statuses'][r['status']] += 1
    except KeyError:
      data['amphora_statuses'][r['status']] = 1

  c.close()
  db.close()

  statuses = {
    'provisioning_status': {},
    'operating_status': {},
    'topology': {},
  }
  for lb in data['loadbalancers']:
    for status in statuses:
      try:
        statuses[status][data['loadbalancers'][lb][status]]['value'] += 1
      except KeyError:
        statuses[status][data['loadbalancers'][lb][status]] = {
          'name': data['loadbalancers'][lb][status],
          'value': 1
        }

  data['loadbalancer_status_summary'] = statuses
  return data

def createOSSummary(data):
  summary = {}
  
  for id in data['nova']['images']:
    try:
      m = ospattern.match(data['glance']['images'][id]['name'])
    except:
      continue
  
    if m:
      os = m.groups()[0]
      try:
        summary[os]['value'] += data['nova']['images'][id]
        summary[os]['images'] += 1 
      except KeyError:
        summary[os] = {
          'name': os,
          'value': data['nova']['images'][id],
          'images': 1
        }

  return summary
