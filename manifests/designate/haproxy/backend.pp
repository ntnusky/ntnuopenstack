# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::designate::haproxy::backend {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $port = lookup('ntnuopenstack::designate::api::port', String)

  ::profile::services::haproxy::backend { 'DesignatePublic':
    backend   => 'bk_designate_public',
    port      => $port,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
