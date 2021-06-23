# Configures the haproxy backends for keystone
class ntnuopenstack::keystone::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'KeystonePublic':
    backend   => 'bk_keystone_public',
    port      => 5000,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'KeystoneInternal':
    backend   => 'bk_keystone_internal',
    port      => 5000,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
