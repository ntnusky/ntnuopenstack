# Configures the haproxy frontend for the public glance API
class ntnuopenstack::glance::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::glance::firewall::haproxy::api

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

  ::profile::services::haproxy::frontend { 'glance_api_admin':
    profile   => 'services',
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
}
