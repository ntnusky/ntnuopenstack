# Configures the haproxy frontend for the public heat API
class ntnuopenstack::heat::haproxy::services {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::serviceapi

  include ::ntnuopenstack::heat::firewall::haproxy
  include ::ntnuopenstack::heat::haproxy::backend::oldpublic

  $ipv4 = hiera('ntnuopenstack::endpoint::public::ipv4')
  $ipv6 = hiera('ntnuopenstack::endpoint::public::ipv6', false)
  $certificate = hiera('ntnuopenstack::endpoint::public::cert', false)
  $certfile = hiera('ntnuopenstack::endpoint::public::cert::certfile',
                    '/etc/ssl/private/haproxy.servicesapi.pem')

  $ft_options = {
    'default_backend' => 'bk_heat_public',
    'reqadd'          => 'X-Forwarded-Proto:\ https',
  }
  $ft_cfn_options = {
    'default_backend' => 'bk_heat_cfn_public',
    'reqadd'          => 'X-Forwarded-Proto:\ https',
  }

  if($certificate) {
    $ssl = ['ssl', 'crt', $certfile]
  } else {
    $ssl = []
  }

  if($ipv6) {
    $bind_api = {
      "${ipv4}:8004" => $ssl,
      "${ipv6}:8004" => $ssl,
    }
    $bind_cfn = {
      "${ipv4}:8000" => $ssl,
      "${ipv6}:8000" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:8004" => $ssl,
    }
    $bind_cfn = {
      "${ipv4}:8000" => $ssl,
    }
  }

  haproxy::frontend { 'ft_heat_public':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_options,
  }

  haproxy::frontend { 'ft_heat_cfn_public':
    bind    => $bind_cfn,
    mode    => 'http',
    options => $ft_cfn_options,
  }

  haproxy::backend { 'bk_heat_public':
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

  haproxy::backend { 'bk_heat_cfn_public':
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
