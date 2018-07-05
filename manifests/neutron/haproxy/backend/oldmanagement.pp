# This class configures haproxy-backends for neutron based on a hiera-key. Can
# be used to include neutron-servers not administerd by the same
# puppet-infrastructure in the rotation.
class ntnuopenstack::neutron::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('ntnuopenstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    profile::services::haproxy::tools::register { "NeutronAdmin-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_neutron_api_admin',
      export      => false,
    }

    haproxy::balancermember { 'neutron-admin-static':
      listening_service => 'bk_neutron_api_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '9696',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
