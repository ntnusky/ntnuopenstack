# Performs the base configuration of keystone 
class ntnuopenstack::keystone::base {
  $region = hiera('ntnuopenstack::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')

  $admin_endpoint = hiera('ntnuopenstack::endpoint::admin',
      "http://${admin_ip}")
  $public_endpoint = hiera('ntnuopenstack::endpoint::public',
      "http://${public_ip}")

  $admin_email = hiera('ntnuopenstack::keystone::admin_email')
  $admin_pass = hiera('ntnuopenstack::keystone::admin_password')
  $admin_token = hiera('ntnuopenstack::keystone::admin_token')

  $mysql_password = hiera('ntnuopenstack::keystone::mysql::password')
  $mysql_old = hiera('profile::mysql::ip', undef)
  $mysql_new = hiera('profile::haproxy::management::ipv4', undef)
  $mysql_ip = pick($mysql_new, $mysql_old)

  $db_con = "mysql://keystone:${mysql_password}@${mysql_ip}/keystone"

  $cache_servers = hiera_array('profile::memcache::servers', false)
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)

  $credential_keys = hiera_hash('ntnuopenstack::keystone::credential::keys')
  $fernet_keys = hiera_hash('ntnuopenstack::keystone::fernet::keys')

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::keystone::tokenflush

  if($cache_servers) {
    $memcache = $cache_servers.map | $server | {
      "${server}:11211"
    }

    $keystone_opts = {
      'memcache_servers' => $memcache,
      'cache_backend'    => 'dogpile.cache.memcached',
      'cache_enabled'    => true,
      'token_caching'    => true,
    }
  } else {
    $keystone_opts = {}
  }

  class { '::keystone':
    admin_token                  => $admin_token,
    admin_password               => $admin_pass,
    database_connection          => $db_con,
    enabled                      => false,
    admin_bind_host              => '0.0.0.0',
    admin_endpoint               => "${admin_endpoint}:35357/",
    public_endpoint              => "${public_endpoint}:5000/",
    token_provider               => 'fernet',
    fernet_keys                  => $fernet_keys,
    enable_fernet_setup          => true,
    credential_keys              => $credential_keys,
    enable_credential_setup      => true,
    enable_proxy_headers_parsing => $confhaproxy,
    using_domain_config          => true,
    *                            => $keystone_opts,
  }

  class { '::keystone::roles::admin':
    email        => $admin_email,
    password     => $admin_pass,
    admin_tenant => 'admin',
    require      => Class['::keystone'],
  }

  class { '::keystone::wsgi::apache':
    servername       => $public_ip,
    servername_admin => $admin_ip,
    ssl              => false,
  }
}
