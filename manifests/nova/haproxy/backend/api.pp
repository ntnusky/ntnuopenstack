# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::api {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'NovaPublic':
    backend   => 'bk_nova_public',
    port      => 8774,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'NovaAdmin':
    backend   => 'bk_nova_api_admin',
    port      => 8774,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
