#!/usr/bin/python3
import sys
import json
from zabbixoslib import keystone_metrics, glance_metrics, nova_metrics, \
  cinder_metrics, heat_metrics, octavia_metrics, magnum_metrics, \
  neutron_metrics, service_status, createOSSummary

if len(sys.argv) < 4:
  print("Usage: %s <mysql-host> <username> <password> [<MISC-PROJECT-ID>]" % sys.argv[0])
  sys.exit(1)

if len(sys.argv) == 5:
  misc = sys.argv[4]
else:
  misc = None

data = {}
data['cinder'] = cinder_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['glance'] = glance_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['heat'] = heat_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['keystone'] = keystone_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['magnum'] = magnum_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['neutron'] = neutron_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['nova'] = nova_metrics(sys.argv[1], sys.argv[2], sys.argv[3], misc)
data['octavia'] = octavia_metrics(sys.argv[1], sys.argv[2], sys.argv[3])
data['service_status'] = service_status(sys.argv[1], sys.argv[2], sys.argv[3])
data['vms_per_os'] = createOSSummary(data)

print(json.dumps(data))
