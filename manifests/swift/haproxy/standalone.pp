# Configures the haproxy frontend for the public swift API, if the swift-api is
# placed on the api-name at port 7480.
class ntnuopenstack::swift::haproxy::standalone {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::swift::firewall::haproxy

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

  ::profile::services::haproxy::frontend { 'swift_public':
    profile   => 'management',
    port      => 7480,
    certfile  => $certfile,
    mode      => 'http',
    bkoptions => {
      'option'  => [
        'httpchk HEAD /',
        'forwardfor',
        'http-server-close',
      ],
      'timeout' => [
        'http-keep-alive 500',
      ],
    },
  }
}
