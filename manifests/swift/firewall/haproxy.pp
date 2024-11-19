# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::haproxy {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  # If no name is set for swift, the service is placed under the regular API
  # endpoint at port 7480. If name is set swift is placed at port 80/443 under
  # the supplied name.
  if(! 'dnsname' in $services[$region]['services']['swift']) {
    ::profile::firewall::custom { 'Swift-API':
      hiera_key => 'profile::networks::openstack::users',
      port      => 7480,
    }
  }
}
