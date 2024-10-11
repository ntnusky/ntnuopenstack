# Configures the firewall to accept incoming traffic to the cinder API. 
class ntnuopenstack::cinder::firewall::haproxy {
  ::profile::firewall::custom { 'Cinder API':
    hiera_key => 'profile::networks::openstack::users', 
    port      => 8776,
  }
}
