# Configures the haproxy backends for barbican
class ntnuopenstack::barbican::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'BarbicanPublic':
    backend   => 'bk_barbican_public',
    port      => 9311,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'BarbicanAdmin':
    backend   => 'bk_barbican_admin',
    port      => 9311,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
