#!/usr/bin/python3
import datetime
from dateutil import tz
import ipaddress
import json
import MySQLdb
import MySQLdb.cursors
import MySQLdb._exceptions
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

def cinder_metrics(host, username, password):
  data = {}  
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='cinder', charset='utf8')

  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT volumes.id, size, status, volume_types.name AS volumetype "\
    "FROM volumes INNER JOIN volume_types "\
    "ON volumes.volume_type_id = volume_types.id where volumes.deleted = '0';")

  data['volumetypes'] = {}
  data['statuses'] = {}
  data['gigabytes'] = 0
  data['volumes'] = 0
  for volume in c.fetchall():
    # Add to the totals 
    data['volumes'] += 1
    data['gigabytes'] += volume['size']

    # Add to the per-volume-type totals
    try:
      data['volumetypes'][volume['volumetype']]['volumes'] += 1
      data['volumetypes'][volume['volumetype']]['gigabytes'] += volume['size']
    except KeyError:
      data['volumetypes'][volume['volumetype']] = {
        'name': volume['volumetype'],
        'volumes': 1,
        'gigabytes': volume['size'],
      }

    # Add to the per-volume-status totals
    try:
      data['statuses'][volume['status']]['volumes'] += 1
      data['statuses'][volume['status']]['gigabytes'] += volume['size']
    except KeyError:
      data['statuses'][volume['status']] = {
        'name': volume['status'],
        'volumes': 1,
        'gigabytes': volume['size'],
      }
      
  return data

def glance_metrics(host, username, password):
  data = {}
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='glance', charset='utf8')

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

def heat_metrics(host, username, password):
  data = {}  
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='heat', charset='utf8')
  
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT id, action, status FROM stack "\
    "WHERE deleted_at IS NULL AND nested_depth = 0")

  data['actions'] = {}
  data['statuses'] = {}
  data['stack_status'] = {}
  data['stacks'] = 0
  for stack in c.fetchall():
    stack_status = '%s_%s' % (stack['action'], stack['status'])
    data['stacks'] += 1

    try:
      data['actions'][stack['action']]['value'] += 1
    except KeyError:
      data['actions'][stack['action']] = {
        'name': stack['action'],
        'value': 1,
      }

    try:
      data['statuses'][stack['status']]['value'] += 1
    except KeyError:
      data['statuses'][stack['status']] = {
        'name': stack['status'],
        'value': 1,
      }

    try:
      data['stack_status'][stack_status]['value'] += 1
    except KeyError:
      data['stack_status'][stack_status] = {
        'name': stack_status,
        'value': 1,
      }

  return data

def keystone_metrics(host, username, password):
  data = {}  
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='keystone', charset='utf8')
  
  # Get the Domain ID
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT id FROM project WHERE is_domain = 1 AND name = 'NTNU'")
  domain_id = c.fetchone()['id']

  # Get all project tags:
  c.execute("SELECT project_id, name FROM project_tag")
  tags = {'notified_delete':[]}
  for t in c.fetchall():
    try:
      tags[t['name']].append(t['project_id'])
    except KeyError:
      tags[t['name']] = [t['project_id']]
  
  # Get the project-list
  c.execute("SELECT id, name, extra, enabled FROM project WHERE is_domain = 0 AND domain_id = %s",
    (domain_id,))
  data['projects'] = {x['id']: {
    'id': x['id'],
    'name': x['name'],
    'enabled': x['enabled'],
    'extra': json.loads(x['extra']),
  } for x in c.fetchall()}

  for p in data['projects']:
    try:
      day,month,year = data['projects'][p]['extra']['expiry'].split('.')
      d = datetime.date(day=int(day), month=int(month), year=int(year))
      data['projects'][p]['expiry'] = data['projects'][p]['extra']['expiry']
      data['projects'][p]['expiry_timestamp'] = d.strftime("%s")
    except (KeyError, ValueError):
      data['projects'][p]['expiry'] = ''
      data['projects'][p]['expiry_timestamp'] = '0'

    data['projects'][p]['notified'] = '1' if p in tags['notified_delete'] else '0'

    data['projects'][p].pop('extra')
  
  # Add summaries
  data['no_projects'] = len(data['projects'])

  c.close()
  db.close()
  return data

def magnum_metrics(host, username, password):
  data = {
    'clusters': {},
    'templates': {},
    'health_status': {},
    'status': {},
  }

  try:
    db = MySQLdb.connect(host=host, user=username, 
      password=password, database='magnum', charset='utf8')
  except MySQLdb._exceptions.OperationalError:
    return data

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

  # Collect clusters
  c.execute("SELECT uuid, name, cluster_template_id, status, health_status FROM cluster")
  for cluster in c.fetchall():
    data['clusters'][cluster['uuid']] = cluster
    if cluster['cluster_template_id'] in data['templates']:
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
    password=password, database='neutron', charset='utf8')
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
    password=password, database='nova', charset='utf8')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  dbapi = MySQLdb.connect(host=host, user=username, 
    password=password, database='nova_api', charset='utf8')
  capi = dbapi.cursor(MySQLdb.cursors.DictCursor)

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

  # Get host-aggregates
  capi.execute("SELECT aggregates.name AS a, aggregate_hosts.host AS h " \
    "FROM aggregate_hosts INNER JOIN aggregates " \
    "ON aggregates.id = aggregate_hosts.aggregate_id")
  data['aggregates'] = {}
  for ha in capi.fetchall():
    try:
      data['aggregates'][ha['a']]['hosts'].append(ha['h'])
    except KeyError:
      data['aggregates'][ha['a']] = {
        'hosts': [ ha['h'] ],
        'name': ha['a'],
        'running_vms': 0,
        'vcpus': 0,
        'vcpus_used': 0,
        'memory_mb': 0, 
        'memory_mb_used': 0,
        'local_gb': 0,
        'local_gb_used': 0,
      }

  # Collect services
  c.execute("SELECT host, disabled, last_seen_up, disabled_reason " \
    "FROM services WHERE topic = 'compute'")
  services = {}
  tz_from = tz.tzutc()
  tz_to = tz.tzlocal()

  for service in c.fetchall():
    try:
      utctime = service['last_seen_up'].replace(tzinfo=tz_from)
    except AttributeError:
      utctime = datetime.datetime(year=2010, day=1, month=1)

    services[service['host']] = {
      'disabled': service['disabled'],
      'disabled_reason': service['disabled_reason'] if service['disabled_reason'] else '',
      'last_seen_up': utctime.astimezone(tz_to).strftime('%s'), 
    }

  # Get hypervisors
  c.execute("SELECT hypervisor_hostname, host, running_vms, " \
    "vcpus, memory_mb, vcpus_used, memory_mb_used, local_gb, local_gb_used " \
    "FROM compute_nodes WHERE deleted = 0")
  data['hypervisors'] = {x['hypervisor_hostname']: x for x in c.fetchall()}

  data['no_hypervisors'] = len(data['hypervisors'])

  data['hypervisor_totals'] = {
    'memory_mb': 0,
    'vcpus': 0,
  }
  for h in data['hypervisors']:
    # Add hypervisor usage to the aggregate usage
    for a in data['aggregates']:
      if data['hypervisors'][h]['host'] in data['aggregates'][a]['hosts']:
        for metric in ['vcpus', 'vcpus_used', 'memory_mb', 'memory_mb_used',
            'local_gb', 'local_gb_used', 'running_vms']:
          data['aggregates'][a][metric] += data['hypervisors'][h][metric]

    # Add hypervisor usage to the global summary
    for v in data['hypervisor_totals']:
      data['hypervisor_totals'][v] += data['hypervisors'][h][v]

    # Add service-info to the hypervisor data
    if data['hypervisors'][h]['host'] in services:
      data['hypervisors'][h]['disabled'] = \
        services[data['hypervisors'][h]['host']]['disabled']
      data['hypervisors'][h]['disabled_reason'] = \
        services[data['hypervisors'][h]['host']]['disabled_reason']
      data['hypervisors'][h]['last_seen_up'] = \
        services[data['hypervisors'][h]['host']]['last_seen_up']

  # Get the MISC project ID
  kdb = MySQLdb.connect(host=host, user=username, 
    password=password, database='keystone', charset='utf8')
  kc = kdb.cursor(MySQLdb.cursors.DictCursor)
  kc.execute("SELECT id FROM project WHERE name = 'MISC'")
  try:
    projectID = kc.fetchone()['id']
  except:
    projectID = None
  kc.close()
  kdb.close()

  # Get UUID of VMs where the deletion-notification is set
  c.execute("SELECT resource_id FROM tags WHERE tag = 'notified_delete'")
  notified = [x['resource_id'] for x in c.fetchall()]

  # Get MISC VM's
  data['misc_vms'] = {}
  if projectID:
    c.execute("SELECT i.uuid,i.hostname,i.vm_state,md.key,md.value FROM instances i " \
      "INNER JOIN instance_metadata md ON i.uuid = md.instance_uuid " \
      "WHERE i.project_id=%s AND i.deleted=0", (projectID,))
    for t in c.fetchall():
      if t['uuid'] not in data['misc_vms']:
        data['misc_vms'][t['uuid']] = {
          'uuid': t['uuid'],
          'hostname': t['hostname'],
          'running': 1 if t['vm_state'] == 'active' else 0,
          'notified': 1 if t['uuid'] in notified else 0,
          'expire': '',
          'expire_timestamp': 0,
          'contact': '',
          'owner': '',
          'topdesk': '',
        }

      if t['key'] in data['misc_vms'][t['uuid']]:
        data['misc_vms'][t['uuid']][t['key']] = t['value']

      if t['key'] == 'expire':
        try:
          day,month,year = t['value'].split('.')
          d = datetime.date(day=int(day), month=int(month), year=int(year))
          data['misc_vms'][t['uuid']]['expire_timestamp'] = d.strftime("%s")
        except (KeyError, ValueError):
          data['misc_vms'][t['uuid']]['expire_timestamp'] = '0'

  c.close()
  db.close()
  return data

def octavia_metrics(host, username, password):
  data = {
    'loadbalancer_status_summary': {
      'provisioning_status': {},
      'operating_status': {},
      'topology': {},
    },
    'amphora_statuses': {},
  }  

  try:
    db = MySQLdb.connect(host=host, user=username, 
      password=password, database='octavia', charset='utf8')
  except MySQLdb._exceptions.OperationalError:
    return data
  
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("select id, name, provisioning_status, operating_status, topology from load_balancer")
  loadbalancers = {x['id']: {
      'id': x['id'],
      'name': x['name'],
      'provisioning_status': x['provisioning_status'],
      'operating_status': x['operating_status'],
      'topology': x['topology'],
    } for x in c.fetchall()
  }

  c.execute("SELECT status FROM amphora")
  for r in c.fetchall():
    try:
      data['amphora_statuses'][r['status']]['value'] += 1
    except KeyError:
      data['amphora_statuses'][r['status']] = {
        'value': 1,
        'name': r['status'],
      }

  c.close()
  db.close()

  for lb in loadbalancers:
    for status in data['loadbalancer_status_summary']:
      try:
        data['loadbalancer_status_summary'][status][loadbalancers[lb][status]]['value'] += 1
      except KeyError:
        data['loadbalancer_status_summary'][status][loadbalancers[lb][status]] = {
          'name': loadbalancers[lb][status],
          'value': 1
        }

  return data

def service_status(host, username, password):
  data = {}

  tz_from = tz.tzutc()
  tz_to = tz.tzlocal()

  # Collect Novas services
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='nova', charset='utf8')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT * FROM services WHERE topic IS NOT NULL AND "\
    "topic != 'compute' AND deleted = '0'")
  for s in c.fetchall():
    utctime = s['last_seen_up'].replace(tzinfo=tz_from)
    data[s['uuid']] = {
      'uuid': s['uuid'],
      'project': 'nova',
      'host': s['host'],
      'service': s['binary'], 
      'service_id': '', 
      'disabled': s['disabled'],
      'disabled_reason': s['disabled_reason'] if s['disabled_reason'] else '',
      'last_seen_up': utctime.astimezone(tz_to).strftime('%s'), 
    }

  # Collect neutron agents 
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='neutron', charset='utf8')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT id, agent_type, `binary`, host, admin_state_up, " \
    "heartbeat_timestamp FROM agents")
  for s in c.fetchall():
    utctime = s['heartbeat_timestamp'].replace(tzinfo=tz_from)
    data[s['id']] = {
      'uuid': s['id'],
      'project': 'neutron',
      'host': s['host'],
      'service': s['binary'],
      'service_id': '', 
      'disabled': 0,
      'disabled_reason': '',
      'last_seen_up': utctime.astimezone(tz_to).strftime('%s'), 
    }

  # Collect cinder services
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='cinder', charset='utf8')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT uuid, host, `binary`, topic, updated_at, disabled, "\
    "disabled_reason FROM services WHERE deleted = '0'")
  for s in c.fetchall():
    utctime = s['updated_at'].replace(tzinfo=tz_from)
    data[s['uuid']] = {
      'uuid': s['uuid'],
      'project': 'cinder',
      'host': s['host'],
      'service': s['binary'], 
      'service_id': '', 
      'disabled': s['disabled'],
      'disabled_reason': s['disabled_reason'] if s['disabled_reason'] else '',
      'last_seen_up': utctime.astimezone(tz_to).strftime('%s'), 
    }

  # Collect heat services
  db = MySQLdb.connect(host=host, user=username, 
    password=password, database='heat', charset='utf8')
  c = db.cursor(MySQLdb.cursors.DictCursor)
  c.execute("SELECT id, engine_id, host, `binary`, updated_at "\
    "FROM service WHERE deleted_at IS NULL")
  for s in c.fetchall():
    utctime = s['updated_at'].replace(tzinfo=tz_from)
    data[s['id']] = {
      'uuid': s['id'],
      'project': 'heat',
      'host': s['host'], 
      'service': s['binary'], 
      'service_id': s['engine_id'],
      'disabled': 0, 
      'disabled_reason': '', 
      'last_seen_up': utctime.astimezone(tz_to).strftime('%s'), 
    }

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
