# Configures the firewall to accept incoming traffic to the placement API.
class ntnuopenstack::placement::firewall::haproxy::global {
  ::profile::firewall::custom { 'Placement-API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 8778,
  }
}
