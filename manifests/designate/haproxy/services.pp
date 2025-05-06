# Configures the haproxy frontend for the public designate API
class ntnuopenstack::designate::haproxy::services {
  require ::profile::services::haproxy

  include ::ntnuopenstack::designate::firewall::haproxy

  $port = lookup('ntnuopenstack::designate::api::port')
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

  ::profile::services::haproxy::frontend { 'designate_public':
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
