# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::placement {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "NovaPlace-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_nova_place_admin',
  }

  @@haproxy::balancermember { "nova-place-${::fqdn}":
    listening_service => 'bk_nova_place_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8778',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
