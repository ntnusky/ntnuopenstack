#!/usr/bin/python3
import sys
import json
from zabbixoslib import glance_metrics, ospattern

if len(sys.argv) < 4:
  print("Usage: %s <mysql-host> <username> <password>" % sys.argv[0])
  sys.exit(1)

images = glance_metrics(sys.argv[1], sys.argv[2], sys.argv[3])['images']
oslist = []

for id in images:
  m = ospattern.match(images[id]['name'])
  if m:
    oslist.append(m.groups()[0])

discovery = []
for os in list(set(oslist)):
  discovery.append({'{#OS}': os})

print(json.dumps(discovery))
