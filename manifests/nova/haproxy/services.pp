# Configures the haproxy frontend for the public nova API
class ntnuopenstack::nova::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::nova::firewall::haproxy

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

  ::profile::services::haproxy::frontend { 'nova_public':
    profile   => 'services',
    port      => 8774,
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

  ::profile::services::haproxy::frontend { 'nova_vnc':
    profile   => 'services',
    port      => 6080,
    certfile  => $certfile,
    mode      => 'tcp',
    bkoptions => {
      'option'  => [
        'tcplog',
        'tcpka',
      ],
    },
  }
}
