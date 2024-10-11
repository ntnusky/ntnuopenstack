# Configures firewall rules for the octavia controller-nodes
class ntnuopenstack::octavia::firewall::controller {
  $health_port = lookup('ntnuopenstack::octavia::heartbeat::port')

  ::profile::firewall::custom { 'amphorae heartbeats':
    hiera_key          => 'ntnuopenstack::octavia::management::networks',
    port               => $health_port,
    transport_protocol => 'udp',
  }
}
