# Configures the haproxy frontend for the internal and admin octavia API
class ntnuopenstack::octavia::haproxy::management {
  include ::ntnuopenstack::octavia::firewall::haproxy
  require ::profile::services::haproxy

  $port = lookup('ntnuopenstack::octavia::api::port')
  $certificate = lookup('ntnuopenstack::endpoint::admin::cert', {
    'default_value' => false,
  })

  if($certificate) {
    include ::ntnuopenstack::cert::api

    $certfile = lookup('ntnuopenstack::endpoint::admin::cert::path', {
      'value_type'    => String,
      'default_value' => '/etc/ssl/private/haproxy.managementapi.pem'
    })
  } else {
    $certfile = false
  }

  ::profile::services::haproxy::frontend { 'octavia_admin':
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
