# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::metadata {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'NovaMetadata':
    backend   => 'bk_nova_metadata',
    port      => 8775,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
