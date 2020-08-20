# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::placement::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "PlacementAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_placement_admin',
  }

  @@haproxy::balancermember { "placement-admin-${::fqdn}":
    listening_service => 'bk_placement_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8778',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "PlacementPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_placement_public',
  }

  @@haproxy::balancermember { "placement-public-${::fqdn}":
    listening_service => 'bk_placement_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8778',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
