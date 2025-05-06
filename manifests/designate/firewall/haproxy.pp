# Configures the firewall to accept incoming traffic to the designate API.
class ntnuopenstack::designate::firewall::haproxy {
  $port = lookup('ntnuopenstack::designate::api::port')

  ::profile::firewall::custom { 'designate-api':
    hiera_key => 'profile::networks::openstack::users',
    port      => $port,
  }
}
