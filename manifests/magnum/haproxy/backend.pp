# Configures the haproxy backends for magnum
class ntnuopenstack::magnum::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "MagnumPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_magnum_public',
  }

  @@haproxy::balancermember { "magnum-public-${::fqdn}":
    listening_service => 'bk_magnum_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9511',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "MagnumAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_magnum_admin',
  }

  @@haproxy::balancermember { "magnum-admin-${::fqdn}":
    listening_service => 'bk_magnum_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9511',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
