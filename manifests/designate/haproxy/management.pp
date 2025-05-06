# Configures the haproxy frontend for the public designate API
class ntnuopenstack::designate::haproxy::management {
  require ::profile::services::haproxy

  include ::ntnuopenstack::designate::firewall::haproxy

  $port = lookup('ntnuopenstack::designate::api::port')
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

  ::profile::services::haproxy::frontend { 'designate_admin':
    profile   => 'management',
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
