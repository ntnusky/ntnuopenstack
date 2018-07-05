# Configures the haproxy frontend for the internal and admin nova API
class ntnuopenstack::nova::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::nova::firewall::haproxy
  include ::ntnuopenstack::nova::haproxy::backend::oldmanagement

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
      "${ipv4}:8774" => $ssl,
      "${ipv6}:8774" => $ssl,
    }
    $bind_metadata = {
      "${ipv4}:8775" => [],
      "${ipv6}:8775" => [],
    }
    $bind_place = {
      "${ipv4}:8778" => $ssl,
      "${ipv6}:8778" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:8774" => $ssl,
    }
    $bind_metadata = {
      "${ipv4}:8775" => [],
    }
    $bind_place = {
      "${ipv4}:8778" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_nova_api_admin',
    'reqadd'          => $proto,
  }
  $ft_metadata_options = {
    'default_backend' => 'bk_nova_metadata',
    'reqadd'          => 'X-Forwarded-Proto:\ http',
  }
  $ft_place_options = {
    'default_backend' => 'bk_nova_place_admin',
    'reqadd'          => $proto,
  }

  haproxy::frontend { 'ft_nova_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }
  haproxy::frontend { 'ft_nova_metadata':
    bind    => $bind_metadata,
    mode    => 'http',
    options => $ft_metadata_options,
  }
  haproxy::frontend { 'ft_nova_place_admin':
    bind    => $bind_place,
    mode    => 'http',
    options => $ft_place_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  profile::services::haproxy::tools::collect { 'bk_nova_api_admin': }
  haproxy::backend { 'bk_nova_api_admin':
    mode    => 'http',
    options => $backend_options,
  }
  profile::services::haproxy::tools::collect { 'bk_nova_metadata': }
  haproxy::backend { 'bk_nova_metadata':
    mode    => 'http',
    options => {
      'balance' => 'source',
      'option'  => [
        'tcplog',
        'tcpka',
      ]
    },
  }
  profile::services::haproxy::tools::collect { 'bk_nova_place_admin': }
  haproxy::backend { 'bk_nova_place_admin':
    mode    => 'http',
    options => $backend_options,
  }
}
