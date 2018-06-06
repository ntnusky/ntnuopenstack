# Installs and configures the glance API
class ntnuopenstack::glance::api {
  # Determine where the database is
  $mysql_pass = hiera('profile::mysql::glancepass')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  # Openstack parameters
  $region = hiera('profile::region')
  $keystone_password = hiera('profile::glance::keystone::password')

  # Determine where the keystone service is located.
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $public_endpoint = hiera('profile::openstack::endpoint::public', undef)
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_public   = pick($public_endpoint, "http://${keystone_public_ip}")

  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)
  $memcache_servers_real = pick($memcache_servers, [$memcached_ip])
  $memcache = $memcache_servers_real.map | $server | {
    "${server}:11211"
  }

  # Variables to determine if haproxy or keepalived should be configured.
  $glance_admin_ip = hiera('profile::api::glance::admin::ip', false)
  $confhaproxy = hiera('profile::openstack::haproxy::configure::backend', true)

  require ::ntnuopenstack::repo
  contain ::ntnuopenstack::glance::ceph
  contain ::ntnuopenstack::glance::firewall::server::api
  include ::ntnuopenstack::glance::sudo
  include ::ntnuopenstack::glance::rabbit
  include ::profile::services::memcache::pythonclient

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::ntnuopenstack::glance::haproxy::backend::server
  }

  # Only configure keepalived if we actually have a shared IP for glance. We
  # use this in the old controller-infrastructure. New infrastructures should be
  # based on haproxy instead.
  if($glance_admin_ip) {
    contain ::ntnuopenstack::glance::keepalived
  }

  class { '::glance::api':
    # Auth_strategy is blank to prevent glance::api from including
    # ::glance::api::authtoken.
    auth_strategy                => '',
    database_connection          => $database_connection,
    enable_proxy_headers_parsing => $confhaproxy,
    keystone_password            => $keystone_password,
    known_stores                 => ['glance.store.rbd.Store'],
    os_region_name               => $region,
    registry_host                => '127.0.0.1',
    show_image_direct_url        => true,
    show_multiple_locations      => true,
  }

  class { '::glance::api::authtoken':
    password          => $keystone_password,
    auth_url          => "${keystone_admin}:35357",
    auth_uri          => "${keystone_public}:5000",
    memcached_servers => $memcache,
    region_name       => $region,
  }

  glance_api_config {
    'DEFAULT/default_store': value => 'rbd';
  }
}
