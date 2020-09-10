# Configures the haproxy frontend for the internal and admin keystone API
class ntnuopenstack::keystone::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::keystone::firewall::haproxy::management

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

  ::profile::services::haproxy::frontend { 'keystone_internal':
    profile   => 'management',
    port      => 5000,
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
