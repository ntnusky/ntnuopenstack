# Configures the haproxy frontend for the public swift API
class ntnuopenstack::swift::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::swift::firewall::haproxy

  $ipv4 = hiera('ntnuopenstack::endpoint::public::ipv4')
  $ipv6 = hiera('ntnuopenstack::endpoint::public::ipv6', false)
  $certificate = hiera('ntnuopenstack::endpoint::public::cert', false)
  $certfile = hiera('ntnuopenstack::endpoint::public::cert::certfile',
                    '/etc/ssl/private/haproxy.servicesapi.pem')

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
    $proto = 'X-Forwarded-Proto:\ https'
  } else {
    $ssl = []
    $proto = 'X-Forwarded-Proto:\ http'
  }

  $ft_options = {
    'default_backend' => 'bk_swift_public',
    'reqadd'          => $proto,
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

  haproxy::frontend { 'ft_swift_public':
    bind    => $bind,
    mode    => 'http',
    options => $ft_options,
  }

  profile::services::haproxy::tools::collect { 'bk_swift_public': }

  haproxy::backend { 'bk_swift_public':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'tcplog',
        'tcpka',
        'httpchk',
      ],
    },
  }
}
