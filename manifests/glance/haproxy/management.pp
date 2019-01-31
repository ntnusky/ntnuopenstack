# Configures the haproxy frontend for the internal and admin glance API and the
# glance registry
class ntnuopenstack::glance::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::glance::firewall::haproxy::api
  include ::ntnuopenstack::glance::firewall::haproxy::registry

  $certificate = lookup('ntnuopenstack::endpoint::admin::cert', {
    'default_value' => false,
  })
  if($certificate) {
    $certfile = lookup('ntnuopenstack::endpoint::admin::cert::path', {
      'value_type'    => String,
      'default_value' => '/etc/ssl/private/haproxy.managementapi.pem'
    })
  } else {
    $certfile = false
  }

  ::profile::services::haproxy::frontend { 'glance_api_admin':
    profile   => 'management',
    port      => 9292,
    certfile  => $certfile,
    mode      => 'http',
    bkoptions => {
      'option'  => [
        'tcplog',
        'tcpka',
        'httpchk',
      ],
    },
  }

  ::profile::services::haproxy::frontend { 'glance_registry':
    profile   => 'management',
    port      => 9191,
    certfile  => $certfile,
    mode      => 'http',
    bkoptions => {
      'option'  => [
        'tcplog',
        'tcpka',
      ],
    },
  }
}
