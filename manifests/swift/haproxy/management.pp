# Configures the haproxy frontend for the swift API 
class ntnuopenstack::swift::haproxy::management {
  $region   = lookup('ntnuopenstack::region', String)
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  if(! 'dnsname' in $services[$region]['services']['swift']) {
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
