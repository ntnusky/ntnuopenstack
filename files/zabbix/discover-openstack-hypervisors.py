#!/usr/bin/python3
import sys
import json
from zabbixoslib import nova_metrics

if len(sys.argv) < 4:
  print("Usage: %s <mysql-host> <username> <password>" % sys.argv[0])
  sys.exit(1)

hypervisors = nova_metrics(sys.argv[1], sys.argv[2], sys.argv[3])['hypervisors']

discovery = []
for id in hypervisors:
  if id:
    discovery.append({'{#HYPERVISOR}': id})

print(json.dumps(discovery))
