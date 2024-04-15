# Configures the haproxy backends for cinder
class ntnuopenstack::cinder::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'CinderPublic':
    backend   => 'bk_cinder_public',
    port      => '8776',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'CinderAdmin':
    backend   => 'bk_cinder_api_admin',
    port      => '8776',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
