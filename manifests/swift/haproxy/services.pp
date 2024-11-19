# Configures the haproxy frontend for the public swift API
class ntnuopenstack::swift::haproxy::services {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  if('dnsname' in $services[$region]['services']['swift']) {
    include ::ntnuopenstack::swift::haproxy::web
  } else {
    include ::ntnuopenstack::swift::haproxy::standalone
  }
}
