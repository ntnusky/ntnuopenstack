# Configures glance registry and backend
class ntnuopenstack::glance::registry {
  # Determine where the database is
  $mysql_pass = lookup('ntnuopenstack::glance::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::keystone::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql://glance:${mysql_pass}@${mysql_ip}/glance"

  # Openstack parameters
  $region = lookup('ntnuopenstack::region', String)
  $keystone_password = lookup('ntnuopenstack::glance::keystone::password', String)

  # Determine where the keystone service is located.
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal', Stdlib::Httpurl)
  $keystone_public = lookup('ntnuopenstack::keystone::endpoint::public', Stdlib::Httpurl)

  # Retrieve addresses for the memcached servers, either the old IP or the new
  # list of hosts.
  $cache_servers = lookup('profile::memcache::servers', {
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })
  $memcache = $cache_servers.map | $server | {
    "${server}:11211"
  }

  # Variables to determine if haproxy or keepalived should be configured.
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  contain ::ntnuopenstack::glance::ceph
  contain ::ntnuopenstack::glance::firewall::server::registry
  include ::ntnuopenstack::glance::sudo
  include ::ntnuopenstack::glance::rabbit
  require ::ntnuopenstack::repo

  if($confhaproxy) {
    contain ::ntnuopenstack::glance::haproxy::backend
  }

  class { '::glance::backend::rbd' :
    rbd_store_user => 'glance',
  }

  class { '::glance::registry':
    # Auth_strategy is blank to prevent glance::registry from including
    # ::glance::registry::authtoken.
    auth_strategy       => '',
    database_connection => $database_connection,
  }

  class { '::glance::registry::authtoken':
    password             => $keystone_password,
    auth_url             => "${keystone_internal}:5000",
    www_authenticate_uri => "${keystone_public}:5000",
    memcached_servers    => $memcache,
    region_name          => $region,
  }
}
