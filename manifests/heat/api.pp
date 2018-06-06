# Installs the heat API
class ntnuopenstack::heat::api {
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)
  $heat_admin_ip = hiera('profile::api::heat::admin::ip', false)

  require ::ntnuopenstack::heat::base
  require ::ntnuopenstack::heat::firewall::api
  require ::ntnuopenstack::repo

  if($heat_admin_ip) {
    contain ::ntnuopenstack::heat::keepalived
  }

  if($confhaproxy) {
    contain ::ntnuopenstack::heat::haproxy::backend::server
  }

  class { '::heat::api' : }
  class { '::heat::api_cfn' : }
}
