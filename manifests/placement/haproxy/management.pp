# Configures the haproxy frontend for the placement API. 
class ntnuopenstack::placement::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::placement::firewall::haproxy::internal

  $standalone = lookup('ntnuopenstack::placement::standalone',
                          Boolean, 'first', false)
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

  if($standalone) {
    ::profile::services::haproxy::frontend { 'placement_admin':
      profile   => 'management',
      port      => 8778,
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
  } else {
    ::profile::services::haproxy::frontend { 'nova_place_admin':
      profile   => 'management',
      port      => 8778,
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
}
