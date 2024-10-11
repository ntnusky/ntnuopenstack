# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::haproxy {
  $swiftname = lookup('ntnuopenstack::swift::dns::name', {
    'default_value' => false,
  })

  # If no name is set for swift, the service is placed under the regular API
  # endpoint at port 7480. If name is set swift is placed at port 80/443 under
  # the supplied name.
  if(! $swiftname) {
    ::profile::firewall::custom { 'Swift-API':
      hiera_key => 'profile::networks::openstack::users',
      port      => 7480,
    }
  }
}
