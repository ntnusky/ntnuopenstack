# Configures the firewall to accept incoming traffic to the glance API. 
class ntnuopenstack::glance::firewall::haproxy::api {
  ::profile::firewall::custom { 'Glance-API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 9292,
  }
}
