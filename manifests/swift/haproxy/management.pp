# Configures the haproxy frontend for the swift API 
class ntnuopenstack::swift::haproxy::management {
  $swiftname = lookup('ntnuopenstack::swift::dns::name', {
    'default_value' => false,
  })

  if(! $swiftname) {
    require ::profile::services::haproxy
    require ::profile::services::haproxy::certs::manageapi

    include ::ntnuopenstack::swift::firewall::haproxy

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

    ::profile::services::haproxy::frontend { 'swift_admin':
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
}
