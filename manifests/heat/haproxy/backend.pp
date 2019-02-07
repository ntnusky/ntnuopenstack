# Configures the haproxy backends for heat
class ntnuopenstack::heat::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "HeatPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_heat_public',
  }

  @@haproxy::balancermember { "heat-public-${::fqdn}":
    listening_service => 'bk_heat_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8004',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "HeatApiAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_heat_api_admin',
  }

  @@haproxy::balancermember { "heat-admin-${::fqdn}":
    listening_service => 'bk_heat_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8004',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "HeatCfnPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_heat_cfn_public',
  }

  @@haproxy::balancermember { "heat-cfn-public-${::fqdn}":
    listening_service => 'bk_heat_cfn_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8000',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "HeatCfnAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_heat_cfn_admin',
  }

  @@haproxy::balancermember { "heat-cfn-admin-${::fqdn}":
    listening_service => 'bk_heat_cfn_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8000',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
