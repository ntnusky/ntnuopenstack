# Configures the haproxy backends for swift
class ntnuopenstack::swift::haproxy::backend {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'SwiftPublic':
    backend   => 'bk_swift_public',
    port      => 7480,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'SwiftAdmin':
    backend   => 'bk_swift_admin',
    port      => 7480,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
