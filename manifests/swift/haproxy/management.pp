# Configures the haproxy frontend for the swift API 
class ntnuopenstack::swift::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::swift::firewall::haproxy

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
    $bind = {
      "${ipv4}:8080" => $ssl,
      "${ipv6}:8080" => $ssl,
    }
  } else {
    $bind = {
      "${ipv4}:8080" => $ssl,
    }
  }

  $ft_options = {
    'default_backend' => 'bk_swift_admin',
    'reqadd'          => $proto,
  }

  haproxy::frontend { 'ft_swift_admin':
    bind    => $bind,
    mode    => 'http',
    options => $ft_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  profile::services::haproxy::tools::collect { 'bk_swift_admin': }

  haproxy::backend { 'bk_swift_admin':
    mode    => 'http',
    options => $backend_options,
  }
}