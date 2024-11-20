# Configures the haproxy frontend for the public nova API
class ntnuopenstack::octavia::haproxy::services {
  include ::ntnuopenstack::octavia::firewall::haproxy
  require ::profile::services::haproxy

  $port = lookup('ntnuopenstack::octavia::api::port')
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

  ::profile::services::haproxy::frontend { 'octavia_public':
    profile   => 'services',
    port      => $port,
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
