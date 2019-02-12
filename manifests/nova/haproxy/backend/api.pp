# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::api {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "NovaPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_nova_public',
  }

  @@haproxy::balancermember { "nova-public-${::fqdn}":
    listening_service => 'bk_nova_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8774',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "NovaAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_nova_api_admin',
  }

  @@haproxy::balancermember { "nova-admin-${::fqdn}":
    listening_service => 'bk_nova_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8774',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
