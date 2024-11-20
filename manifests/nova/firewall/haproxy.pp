# Configures the firewall to accept incoming traffic to the nova API. 
class ntnuopenstack::nova::firewall::haproxy {
  ::profile::firewall::custom { 'Nova-API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 8774,
  }
  ::profile::firewall::custom { 'Nova-VNCProxy':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 6080,
  }
}
