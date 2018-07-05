# Configures the haproxy backends for neutron
class ntnuopenstack::neutron::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "NeutronPublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_neutron_public',
  }
  @@haproxy::balancermember { "neutron-public-${::fqdn}":
    listening_service => 'bk_neutron_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9696',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "NeutronAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_neutron_api_admin',
  }
  @@haproxy::balancermember { "neutron-admin-${::fqdn}":
    listening_service => 'bk_neutron_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9696',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
