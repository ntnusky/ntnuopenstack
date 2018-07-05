# This class configures haproxy-backends for keystone based on a hiera-key. Can
# be used to include keystone-servers not administerd by the same
# puppet-infrastructure in the rotation.
class ntnuopenstack::keystone::haproxy::backend::oldmanagement {
  $controllers = hiera_hash('ntnuopenstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    profile::services::haproxy::tools::register { "KeystoneAdmin-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_keystone_admin',
      export      => false,
    }

    haproxy::balancermember { 'keystone-admin-static':
      listening_service => 'bk_keystone_admin',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '35357',
      options           => 'check inter 2000 rise 2 fall 5',
    }

    profile::services::haproxy::tools::register { "KeystoneInternal-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_keystone_internal',
      export      => false,
    }

    haproxy::balancermember { 'keystone-internal-static':
      listening_service => 'bk_keystone_internal',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '5000',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
