# Configures the haproxy frontend for the public glance API
class ntnuopenstack::glance::haproxy::services {
  include ::ntnuopenstack::glance::firewall::haproxy::api
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

  ::profile::services::haproxy::frontend { 'glance_public':
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
