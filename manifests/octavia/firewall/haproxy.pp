# Configures firewall rules for the octavia controller-nodes
class ntnuopenstack::octavia::firewall::haproxy {
  $port = lookup('ntnuopenstack::octavia::api::port')

  ::profile::baseconfig::firewall::service::global { 'octavia API':
    protocol => 'tcp',
    port     => $port,
  }
}
