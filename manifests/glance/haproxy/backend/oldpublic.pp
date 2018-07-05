# This class configures haproxy-backends for glance based on a hiera-key. Can
# be used to include glance-servers not administerd by the same
# puppet-infrastructure in the rotation.
class ntnuopenstack::glance::haproxy::backend::oldpublic {
  $controllers = hiera_hash('ntnuopenstack::oldcontrollers', false)

  if($controllers) {
    $names = keys($controllers)
    $addresses = values($controllers)

    profile::services::haproxy::tools::register { "Glance_public-${::hostname}":
      servername  => $::hostname,
      backendname => 'bk_glance_public',
      export      => false,
    }

    haproxy::balancermember { 'glance-public-static':
      listening_service => 'bk_glance_public',
      server_names      => $names,
      ipaddresses       => $addresses,
      ports             => '9292',
      options           => 'check inter 2000 rise 2 fall 5',
    }
  }
}
