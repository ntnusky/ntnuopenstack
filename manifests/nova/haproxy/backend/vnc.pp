# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::vnc {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "NovaVNC-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_nova_vnc',
  }

  @@haproxy::balancermember { "nova-vnc-${::fqdn}":
    listening_service => 'bk_nova_vnc',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '6080',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
