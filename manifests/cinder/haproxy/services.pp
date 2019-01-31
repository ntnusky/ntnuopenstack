# Configures the haproxy frontend for the public cinder API
class ntnuopenstack::cinder::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::cinder::firewall::haproxy

  $certificate = lookup('ntnuopenstack::endpoint::public::cert', {
    'default_value' => false,
  })
  if($certificate) {
    $certfile = hiera('ntnuopenstack::endpoint::public::cert::path', {
      'value_type'    => String,
      'default_value' => '/etc/ssl/private/haproxy.managementapi.pem'
    })
  } else {
    $certfile = false
  }

  ::profile::services::haproxy::frontend { 'cinder_public':
    profile   => 'management',
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
