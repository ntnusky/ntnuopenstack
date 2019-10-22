# Configures the haproxy backends for keystone
class ntnuopenstack::keystone::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "KeystonePublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_keystone_public',
  }

  @@haproxy::balancermember { "keystone-public-${::fqdn}":
    listening_service => 'bk_keystone_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '5000',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "KeystoneInternal-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_keystone_internal',
  }

  @@haproxy::balancermember { "keystone-internal-${::fqdn}":
    listening_service => 'bk_keystone_internal',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '5000',
    options           => 'check inter 2000 rise 2 fall 5',
  }
 
  # To be removed in the TRAIN relase:
  #
  # The keystone admin interface (port 35357) is deprecated, and removed in
  # Stein. We have services using 35357 in the rocky relase, so to allow smooth
  # upgrades we let the keystone-admin haproxy service live until Train. It is
  # however connected to the regular keystone port behind the load-balancer.
  profile::services::haproxy::tools::register { "KeystoneAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_keystone_admin',
  }

  @@haproxy::balancermember { "keystone-admin-${::fqdn}":
    listening_service => 'bk_keystone_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '5000',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
