# Configure firewall rules for haproxy-magnum
class ntnuopenstack::magnum::firewall::haproxy {
  ::profile::firewall::custom { 'Magnum-API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 9511,
  }
}
