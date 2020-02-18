# Configures firewall rules for the octavia controller-nodes
class ntnuopenstack::octavia::firewall::controller {
  $octavia_management = lookup(
    'ntnuopenstack::octavia::management::ipv4::network', {
      'value_type' => Stdlib::IP::Address::V4::CIDR,
    }
  )
  $health_port = lookup('ntnuopenstack::octavia::heartbeat::port', Stdlib::Port)

  ::profile::baseconfig::firewall::service::custom { 'amphorae heartbeats':
    protocol => 'udp',
    port     => $health_port,
    v4source => $octavia_management,
  }
}
