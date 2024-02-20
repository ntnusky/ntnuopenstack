# Configures the haproxy backends for neutron
class ntnuopenstack::neutron::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'NeutronPublic':
    backend   => 'bk_neutron_public',
    port      => '9696',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'NeutronAdmin':
    backend   => 'bk_neutron_api_admin',
    port      => '9696',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
