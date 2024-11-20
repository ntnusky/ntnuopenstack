# Configures the haproxy frontend for the internal and admin glance API
class ntnuopenstack::glance::haproxy::management {
  include ::ntnuopenstack::glance::firewall::haproxy::api
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

  ::profile::services::haproxy::frontend { 'glance_api_admin':
    profile   => 'management',
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
