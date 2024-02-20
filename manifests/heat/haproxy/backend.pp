# Configures the haproxy backends for heat
class ntnuopenstack::heat::haproxy::backend {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })

  ::profile::services::haproxy::backend { 'HeatPublic':
    backend   => 'bk_heat_public',
    port      => '8004',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'HeatAdmin':
    backend   => 'bk_heat_api_admin',
    port      => '8004',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'HeatCfnPublic':
    backend   => 'bk_heat_cfn_public',
    port      => '8000',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'HeatCfnAdmin':
    backend   => 'bk_heat_cfn_admin',
    port      => '8000',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
