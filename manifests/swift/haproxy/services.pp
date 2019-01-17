# Configures the haproxy frontend for the public swift API
class ntnuopenstack::swift::haproxy::services {
  $swiftname = lookup('ntnuopenstack::swift::dns::name', {
    'default_value' => False,
  })

  if($swiftname) {

  } else {
    include ::ntnuopenstack::swift::haproxy::standalone
  }
}
