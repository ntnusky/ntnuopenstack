# Configures firewall rules for the octavia controller-nodes
class ntnuopenstack::octavia::firewall::haproxy {
  $port = lookup('ntnuopenstack::octavia::api::port')

  ::profile::firewall::custom { 'octavia API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => $port,
  }
}
