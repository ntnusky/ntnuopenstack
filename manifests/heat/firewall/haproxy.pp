# Configures the firewall to accept incoming traffic to the heat API. 
class ntnuopenstack::heat::firewall::haproxy {
  ::profile::firewall::custom { 'Heat-API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => [8000,8004],
  }
}
