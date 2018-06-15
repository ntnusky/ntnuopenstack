# Installs and configures the cinder API
class ntnuopenstack::cinder::api {
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', false)

  include ::cinder::db::sync
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::cinder::base
  contain ::ntnuopenstack::cinder::firewall::server
  include ::profile::services::memcache::pythonclient

  if($keystone_admin_ip) {
    contain ::ntnuopenstack::cinder::keepalived
  }

  if($confhaproxy) {
    contain ::ntnuopenstack::cinder::haproxy::backend::server
  }

  class { '::cinder::api':
    enabled                      => true,
    default_volume_type          => 'Normal',
    enable_proxy_headers_parsing => $confhaproxy,
  }
}
