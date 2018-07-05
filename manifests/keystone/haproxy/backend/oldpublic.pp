# This class configures haproxy-backends for keystone based on a hiera-key. Can
# be used to include keystone-servers not administerd by the same
# puppet-infrastructure in the rotation.
class ntnuopenstack::keystone::haproxy::backend::oldpublic {
  $controllers = hiera_hash('ntnuopenstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    profile::services::haproxy::tools::register { "KeystonePublic-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_keystone_public',
      export      => false,
    }

    haproxy::balancermember { 'keystone-public-static':
      listening_service => 'bk_keystone_public',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '5000',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
