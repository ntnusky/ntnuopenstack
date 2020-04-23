# Configures the haproxy backends for barbican
class ntnuopenstack::barbican::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "BarbicanPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_barbican_public',
  }

  @@haproxy::balancermember { "barbican-public-${::fqdn}":
    listening_service => 'bk_barbican_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9311',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "BarbicanAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_barbican_admin',
  }

  @@haproxy::balancermember { "barbican-admin-${::fqdn}":
    listening_service => 'bk_barbican_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9311',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
