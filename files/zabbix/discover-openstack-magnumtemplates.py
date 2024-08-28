#!/usr/bin/python3
import sys
import json
from zabbixoslib import magnum_metrics

if len(sys.argv) < 4:
  print("Usage: %s <mysql-host> <username> <password>" % sys.argv[0])
  sys.exit(1)

templates = magnum_metrics(sys.argv[1], sys.argv[2], sys.argv[3])['templates']

discovery = []
for id in templates:
  if templates[id]['hidden'] == 0:
    discovery.append({'{#MAGNUM-TEMPLATE}': id})

print(json.dumps(discovery))
