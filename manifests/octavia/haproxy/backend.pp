# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::octavia::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $port = lookup('ntnuopenstack::octavia::api::port', Stdlib::Port)
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "OctaviaPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_octavia_public',
  }

  @@haproxy::balancermember { "octavia-public-${::fqdn}":
    listening_service => 'bk_octavia_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => $port,
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "OctaviaAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_octavia_admin',
  }

  @@haproxy::balancermember { "nova-admin-${::fqdn}":
    listening_service => 'bk_octavia_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => $port,
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
