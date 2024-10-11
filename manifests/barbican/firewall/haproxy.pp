# Configure firewall rules for haproxy-barbican
class ntnuopenstack::barbican::firewall::haproxy {
  ::profile::firewall::custom { 'barbican-API':
    hiera_key => 'profile::networks::openstack::users',
    port      => 9311,
  }
}
