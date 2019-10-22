# Configures the haproxy backends for glance
class ntnuopenstack::glance::haproxy::backend {
  $if = lookup('profile::interfaces::management')
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "GlancePublic-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_glance_public',
  }

  @@haproxy::balancermember { "glance-public-${::fqdn}":
    listening_service => 'bk_glance_public',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9292',
    options           => 'check inter 2000 rise 2 fall 5',
  }

  profile::services::haproxy::tools::register { "GlanceAdmin-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_glance_api_admin',
  }

  @@haproxy::balancermember { "glance-admin-${::fqdn}":
    listening_service => 'bk_glance_api_admin',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9292',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
