# Configures glance registry and backend
class ntnuopenstack::glance::registry {
  $region = hiera('ntnuopenstack::region')
  $keystone_password = hiera('ntnuopenstack::glance::keystone::password')
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)

  # Determine the correct endpoint for keystone
  $admin_endpoint = hiera('ntnuopenstack::endpoint::admin', undef)
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', undef)
  $public_endpoint = hiera('ntnuopenstack::endpoint::public', undef)
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")
  $keystone_internal = pick($internal_endpoint, "http://${keystone_admin_ip}")
  $keystone_public   = pick($public_endpoint, "http://${keystone_public_ip}")

  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $memcached_ip = hiera('profile::memcache::ip', undef)
  $memcache_servers = hiera_array('profile::memcache::servers', undef)
  $memcache_servers_real = pick($memcache_servers, [$memcached_ip])
  $memcache = $memcache_servers_real.map | $server | {
    "${server}:11211"
  }

  # Determine how we connect to the database
  $mysql_pass = hiera('ntnuopenstack::glance::mysql::password')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  contain ::ntnuopenstack::glance::ceph
  contain ::ntnuopenstack::glance::firewall::server::registry
  include ::ntnuopenstack::glance::sudo
  include ::ntnuopenstack::glance::rabbit
  require ::ntnuopenstack::repo

  if($confhaproxy) {
    contain ::ntnuopenstack::glance::haproxy::backend::server
  }

  class { '::glance::backend::rbd' :
    rbd_store_user => 'glance',
  }

  class { '::glance::registry':
    # Auth_strategy is blank to prevent glance::registry from including
    # ::glance::registry::authtoken.
    auth_strategy       => '',
    database_connection => $database_connection,
    keystone_password   => $keystone_password,
  }

  class { '::glance::registry::authtoken':
    password          => $keystone_password,
    auth_url          => "${keystone_admin}:35357",
    auth_uri          => "${keystone_public}:5000",
    memcached_servers => $memcache,
    region_name       => $region,
  }
}
