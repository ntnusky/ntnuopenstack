# Configures the haproxy frontend for the internal and admin heat API
class ntnuopenstack::heat::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::heat::firewall::haproxy

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

  ::profile::services::haproxy::frontend { 'heat_api_admin':
    profile   => 'management',
    port      => 8004,
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

  ::profile::services::haproxy::frontend { 'heat_cfn_admin':
    profile   => 'management',
    port      => 8000,
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
}
