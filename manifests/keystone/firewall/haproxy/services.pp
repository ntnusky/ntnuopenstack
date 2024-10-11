# Opens the firewall for the keystone port from any source
class ntnuopenstack::keystone::firewall::haproxy::services {
  ::profile::firewall::custom { 'Keystone-Public':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 5000,
  }
}
