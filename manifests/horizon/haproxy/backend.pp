# Configures a haproxy server for horizon.
class ntnuopenstack::horizon::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "Horizon-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_horizon',
  }

  @@haproxy::balancermember { "horizon-${::fqdn}":
    listening_service => 'bk_horizon',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '80',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
