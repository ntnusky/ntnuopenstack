# Configures the haproxy backends for glance
class ntnuopenstack::glance::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'GlancePublic':
    backend   => 'bk_glance_public',
    port      => '9292',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'GlanceAdmin':
    backend   => 'bk_glance_api_admin',
    port      => '9292',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
