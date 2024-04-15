# Configures the haproxy backends for magnum
class ntnuopenstack::magnum::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'MagnumPublic':
    backend   => 'bk_magnum_public',
    port      => '9511',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'MagnumAdmin':
    backend   => 'bk_magnum_admin',
    port      => '9511',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
