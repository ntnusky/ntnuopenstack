# Configures the haproxy frontend for the internal and admin glance API and the
# glance registry
class ntnuopenstack::glance::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::glance::firewall::haproxy::api
  include ::ntnuopenstack::glance::firewall::haproxy::registry
  include ::ntnuopenstack::glance::haproxy::backend::oldmanagement

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
      "${ipv4}:9292" => $ssl,
      "${ipv6}:9292" => $ssl,
    }
    $bind_reg = {
      "${ipv4}:9191" => $ssl,
      "${ipv6}:9191" => $ssl,
    }
  } else {
    $bind_api = {
      "${ipv4}:9292" => $ssl,
    }
    $bind_reg = {
      "${ipv4}:9191" => $ssl,
    }
  }

  $ft_api_options = {
    'default_backend' => 'bk_glance_api_admin',
    'reqadd'          => $proto,
  }
  $ft_reg_options = {
    'default_backend' => 'bk_glance_registry',
    'reqadd'          => $proto,
  }

  haproxy::frontend { 'ft_glance_api_admin':
    bind    => $bind_api,
    mode    => 'http',
    options => $ft_api_options,
  }
  haproxy::frontend { 'ft_glance_registry':
    bind    => $bind_reg,
    mode    => 'http',
    options => $ft_reg_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }
  $backend_reg_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
    ],
  }

  profile::services::haproxy::tools::collect { 'bk_glance_api_admin': }

  haproxy::backend { 'bk_glance_api_admin':
    mode    => 'http',
    options => $backend_options,
  }

  profile::services::haproxy::tools::collect { 'bk_glance_registry': }

  haproxy::backend { 'bk_glance_registry':
    mode    => 'http',
    options => $backend_reg_options,
  }
}
