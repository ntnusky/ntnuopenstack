# Creates the databases for the placement service.
class ntnuopenstack::placement::api {
  # Determine database-settings
  $mysql_pass = lookup('ntnuopenstack::placement::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::placement::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://placement:${mysql_pass}@${mysql_ip}/placement"
  $db_sync = lookup('ntnuopenstack::placement::db::sync̈́', Boolean)

  # Retrieve openstack-settings
  $region = lookup('ntnuopenstack::region', String)
  $keystone_password = lookup('ntnuopenstack::placement::keystone::password',
                                String)
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
                                Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public',
                                Stdlib::Httpurl)

  # Retrieve addresses for the memcached servers
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  # Determining if the server is placed behind haproxy
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::repo
  include ::ntnuopenstack::placement::firewall::server

  if($confhaproxy) {
    contain ::ntnuopenstack::placement::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::placement':
    sync_db => $db_sync,
  }

  class { '::placement::db':
    database_connection => $database_connection,
  }

  class { '::placement::keystone::authtoken':
    password             => $keystone_password,
    auth_url             => "${keystone_internal}:5000",
    www_authenticate_uri => "${keystone_public}:5000",
    memcached_servers    => $memcache,
    region_name          => $region,
  }

  class { '::placement::wsgi::apache':
    api_port          => 8778,
    ssl               => false,
    access_log_format => $logformat,
  }
}
