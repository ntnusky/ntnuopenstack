#!/usr/bin/python3
import sys
import json
from zabbixoslib import neutron_metrics

if len(sys.argv) < 4:
  print("Usage: %s <mysql-host> <username> <password>" % sys.argv[0])
  sys.exit(1)

pools = neutron_metrics(sys.argv[1], sys.argv[2], sys.argv[3])['subnet_pools']

discovery = []
for id in pools:
  discovery.append({'{#SUBNETPOOL-ID}': id})

print(json.dumps(discovery))
