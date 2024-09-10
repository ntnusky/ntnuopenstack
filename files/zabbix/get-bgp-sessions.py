#!/usr/bin/python3
import datetime
import json
import psutil

connections = psutil.net_connections()
active = {}

for c in connections:
  try:
    local = c.laddr.port
  except:
    local = 0

  try:
    remote = c.raddr.port
  except:
    remote = 0
  
  if local == 179 or remote == 179 and c.status == 'ESTABLISHED':
    active[c.raddr.ip] = {
      'initiator': 'local' if remote == 179 else 'remote',
      'local_port': local,
      'remote_port': remote,
      'local_ip': c.laddr.ip,
      'remote_ip': c.raddr.ip,
      'last_seen': datetime.datetime.now().strftime('%s'),
    }

print(json.dumps(active))
