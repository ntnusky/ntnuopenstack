# Configures the haproxy frontend for the public glance API
class ntnuopenstack::glance::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::glance::firewall::haproxy::api
  include ::ntnuopenstack::glance::haproxy::backend::oldpublic

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
    'default_backend' => 'bk_glance_public',
    'reqadd'          => $proto,
  }

  if($ipv6) {
    $bind = {
      "${ipv4}:9292" => $ssl,
      "${ipv6}:9292" => $ssl,
    }
  } else {
    $bind = {
      "${ipv4}:9292" => $ssl,
    }
  }

  haproxy::frontend { 'ft_glance_public':
    bind    => $bind,
    mode    => 'http',
    options => $ft_options,
  }

  haproxy::backend { 'bk_glance_public':
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
