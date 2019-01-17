# Configures the haproxy frontend for the public swift API
class ntnuopenstack::swift::haproxy::services {
  $swiftname = lookup('ntnuopenstack::swift::dns::name', {
    'default_value' => false,
  })

  if($swiftname) {
    include ::ntnuopenstack::swift::haproxy::web
  } else {
    include ::ntnuopenstack::swift::haproxy::standalone
  }
}
