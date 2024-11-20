# Configures the haproxy frontend for the internal and admin cinder API
class ntnuopenstack::cinder::haproxy::management {
  include ::ntnuopenstack::cinder::firewall::haproxy
  require ::profile::services::haproxy

  $certificate = lookup('ntnuopenstack::endpoint::admin::cert', {
    'default_value' => false,
  })
  if($certificate) {
    include ::ntnuopenstack::cert::adminapi

    $certfile = lookup('ntnuopenstack::endpoint::admin::cert::path', {
      'value_type'    => String,
      'default_value' => '/etc/ssl/private/haproxy.managementapi.pem'
    })
  } else {
    $certfile = false
  }

  ::profile::services::haproxy::frontend { 'cinder_api_admin':
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
