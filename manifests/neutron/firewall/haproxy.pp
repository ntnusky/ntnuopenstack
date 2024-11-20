# Configures the firewall to accept incoming traffic to the neutron API. 
class ntnuopenstack::neutron::firewall::haproxy {
  ::profile::firewall::custom { 'Neutron-API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 9696,
  }
}
