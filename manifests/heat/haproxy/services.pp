# Configures the haproxy frontend for the public heat API
class ntnuopenstack::heat::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::heat::firewall::haproxy

  $certificate = lookup('ntnuopenstack::endpoint::public::cert', {
    'default_value' => false,
  })
  if($certificate) {
    $certfile = lookup('ntnuopenstack::endpoint::public::cert::path', {
      'value_type'    => String,
      'default_value' => '/etc/ssl/private/haproxy.servicesapi.pem'
    })
  } else {
    $certfile = false
  }

  ::profile::services::haproxy::frontend { 'heat_public':
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

  ::profile::services::haproxy::frontend { 'heat_cfn_public':
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
