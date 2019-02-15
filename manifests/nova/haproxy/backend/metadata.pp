# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::metadata {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "NovaMetadata-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_nova_metadata',
  }

  @@haproxy::balancermember { "nova-metadata-${::fqdn}":
    listening_service => 'bk_nova_metadata',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '8775',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
