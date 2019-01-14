# Configures the haproxy backends for swift
class ntnuopenstack::swift::haproxy::backend {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "SwiftPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_swift_public',
  }

  @@haproxy::balancermember { "swift-public-${::fqdn}":
    listening_service => 'bk_swift_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8080',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "SwiftAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_swift_admin',
  }

  @@haproxy::balancermember { "swift-admin-${::fqdn}":
    listening_service => 'bk_swift_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8080',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
