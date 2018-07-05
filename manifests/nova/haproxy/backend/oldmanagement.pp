# This class configures haproxy-backends for nova based on a hiera-key. Can
# be used to include nova-servers not administerd by the same
# puppet-infrastructure in the rotation.
class ntnuopenstack::nova::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('ntnuopenstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    profile::services::haproxy::tools::register { "NovaAdminApi-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_nova_api_admin',
      export      => false,
    }

    haproxy::balancermember { 'nova-admin-static':
      listening_service => 'bk_nova_api_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '8774',
      options           => 'check inter 2000 rise 2 fall 5',
    }

    profile::services::haproxy::tools::register { "NovaPublic-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_nova_place_admin',
      export      => false,
    }

    haproxy::balancermember { 'nova-place-static':
      listening_service => 'bk_nova_place_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '8778',
      options           => 'check inter 2000 rise 2 fall 5',
    }

    profile::services::haproxy::tools::register { "NovaMetadata-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_nova_metadata',
      export      => false,
    }

    haproxy::balancermember { 'nova-metadata-static':
      listening_service => 'bk_nova_metadata',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '8775',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
