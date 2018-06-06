# Configures the haproxy frontend for the internal and admin keystone API
class ntnuopenstack::keystone::haproxy::management {
  require ::profile::services::haproxy
  require ::profile::services::haproxy::certs::manageapi

  include ::ntnuopenstack::keystone::firewall::haproxy::management
  include ::ntnuopenstack::keystone::haproxy::backend::oldmanagement

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
    $bind_adm = {
      "${ipv4}:35357" => $ssl,
      "${ipv6}:35357" => $ssl,
    }
    $bind_int = {
      "${ipv4}:5000" => $ssl,
      "${ipv6}:5000" => $ssl,
    }
  } else {
    $bind_adm = {
      "${ipv4}:35357" => $ssl,
    }
    $bind_int = {
      "${ipv4}:5000" => $ssl,
    }
  }

  $ft_admin_options = {
    'default_backend' => 'bk_keystone_admin',
    'reqadd'          => $proto,
  }
  $ft_internal_options = {
    'default_backend' => 'bk_keystone_internal',
    'reqadd'          => $proto,
  }

  haproxy::frontend { 'ft_keystone_admin':
    bind    => $bind_adm,
    mode    => 'http',
    options => $ft_admin_options,
  }
  haproxy::frontend { 'ft_keystone_internal':
    bind    => $bind_int,
    mode    => 'http',
    options => $ft_internal_options,
  }

  $backend_options = {
    'balance' => 'source',
    'option'  => [
      'tcplog',
      'tcpka',
      'httpchk',
    ],
  }

  haproxy::backend { 'bk_keystone_admin':
    mode    => 'http',
    options => $backend_options,
  }

  haproxy::backend { 'bk_keystone_internal':
    mode    => 'http',
    options => $backend_options,
  }
}
