# Configures the haproxy frontend for the public cinder API
class ntnuopenstack::cinder::haproxy::services {
  include ::ntnuopenstack::cinder::firewall::haproxy
  require ::profile::services::haproxy

  $certificate = lookup('ntnuopenstack::endpoint::public::cert', {
    'default_value' => false,
  })
  if($certificate) {
    include ::ntnuopenstack::cert::api

    $certfile = lookup('ntnuopenstack::endpoint::public::cert::path', {
      'value_type'    => String,
      'default_value' => '/etc/ssl/private/haproxy.servicesapi.pem'
    })
  } else {
    $certfile = false
  }

  ::profile::services::haproxy::frontend { 'cinder_public':
    profile   => 'services',
    port      => 8776,
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
