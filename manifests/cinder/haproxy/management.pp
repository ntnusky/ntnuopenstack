# Configures the haproxy frontend for the internal and admin cinder API
class ntnuopenstack::cinder::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::cinder::firewall::haproxy
  include ::ntnuopenstack::cinder::haproxy::backend::oldmanagement

  $ipv4 = hiera('ntnuopenstack::endpoint::admin::ipv4')
  $ipv6 = hiera('ntnuopenstack::endpoint::admin::ipv6', false)
  $certificate = hiera('ntnuopenstack::endpoint::admin::cert', false)
  $certfile = hiera('ntnuopenstack::endpoint::admin::cert::path',
                    '/etc/ssl/private/haproxy.managementapi.pem')

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
    $proto = 'X-Forwarded-Proto:\ https'
  } else {
    $ssl = []
    $proto = 'X-Forwarded-Proto:\ http'
  }

  if($ipv6) {
    $bind_api = {
      "${ipv4}:8776" => $ssl,
      "${ipv6}:8776" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:8776" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_cinder_api_admin',
    'reqadd'          => $proto,
  }

  haproxy::frontend { 'ft_cinder_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  haproxy::backend { 'bk_cinder_api_admin':
    mode    => 'http',
    options => $backend_options,
  }
}
