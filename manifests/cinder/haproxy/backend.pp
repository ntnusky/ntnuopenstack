# Configures the haproxy backends for cinder
class ntnuopenstack::cinder::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "CinderPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_cinder_public',
  }

  @@haproxy::balancermember { "cinder-public-${::fqdn}":
    listening_service => 'bk_cinder_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8776',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "CinderAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_cinder_api_admin',
  }

  @@haproxy::balancermember { "cinder-admin-${::fqdn}":
    listening_service => 'bk_cinder_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8776',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
