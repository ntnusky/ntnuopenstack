#!/usr/bin/python3
import sys
import json
from zabbixoslib import keystone_metrics, glance_metrics, nova_metrics, \
  octavia_metrics, magnum_metrics, neutron_metrics, createOSSummary

if len(sys.argv) < 4:
  print("Usage: %s <mysql-host> <username> <password>" % sys.argv[0])
  sys.exit(1)

data = {}
data['keystone'] = keystone_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['glance'] = glance_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['nova'] = nova_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['octavia'] = octavia_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['magnum'] = magnum_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['neutron'] = neutron_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['vms_per_os'] = createOSSummary(data)

print(json.dumps(data))
