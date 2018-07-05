# Configures the haproxy backends for glance
class ntnuopenstack::glance::haproxy::backend::server {
  $if = hiera('profile::interfaces::management')
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

  profile::services::haproxy::tools::register { "GlanceRegistry-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_glance_registry',
  }

  @@haproxy::balancermember { "glance-registry-${::fqdn}":
    listening_service => 'bk_glance_registry',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '9191',
    options           => 'check inter 2000 rise 2 fall 5',
  }
}
