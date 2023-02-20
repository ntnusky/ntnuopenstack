# Installs the octavia API.
class ntnuopenstack::octavia::api {
  $api_port = lookup('ntnuopenstack::octavia::api::port', Stdlib::Port)
  $dbsync = lookup('ntnuopenstack::octavia::db::sync', Boolean, 'first', false)

  $register_loadbalancer = lookup('profile::haproxy::register', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  require ::ntnuopenstack::octavia::auth
  include ::ntnuopenstack::octavia::base
  include ::ntnuopenstack::octavia::firewall::api
  include ::ntnuopenstack::octavia::haproxy::backend
  require ::ntnuopenstack::repo

  class { '::octavia::api':
    api_v1_enabled               => false,
    enable_proxy_headers_parsing => $register_loadbalancer,
    port                         => $api_port,
    sync_db                      => $dbsync,
  }
}
