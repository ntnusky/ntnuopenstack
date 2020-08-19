# Installs and configures the glance API
class ntnuopenstack::glance::api {
  # Determine where the database is
  $mysql_pass= lookup('ntnuopenstack::glance::mysql::password', String)
  $mysql_ip = lookup('ntnuopenstack::glance::mysql::ip', Stdlib::IP::Address)
  $database_connection = "mysql+pymysql://glance:${mysql_pass}@${mysql_ip}/glance"
  $db_sync = lookup('ntnuopenstack::glance::db::sync', Boolean)

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

  $horizon_fqdn = lookup('ntnuopenstack::horizon::server_name')
  $horizon_url = "https://${horizon_fqdn}"
  $upload_mode = lookup('ntnuopenstack::horizon::upload_mode', {
    'value_type'   => Enum['legacy', 'direct', 'off'],
    'default_value' => 'legacy',
  })

  $disk_formats = lookup('ntnuopenstack::glance::disk_formats', {
    'value_type'    => Hash[String, String],
    'default_value' => {'raw' => '', 'qcow2' => ''}
  })
  $container_formats = lookup('ntnuopenstack::glance::container_formats', {
    'value_type'    => Array[String],
    'default_value' => ['bare'],
  })

  $disk_formats_real = join(keys($disk_formats), ',')
  $container_formats_real = join($container_formats, ',')

  require ::ntnuopenstack::repo
  contain ::ntnuopenstack::glance::ceph
  contain ::ntnuopenstack::glance::firewall::server::api
  include ::ntnuopenstack::glance::sudo
  include ::ntnuopenstack::glance::rabbit
  include ::profile::services::memcache::pythonclient
  include ::profile::monitoring::munin::plugin::openstack::glance

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::ntnuopenstack::glance::haproxy::backend
  }

  class { '::glance::api':
    # Auth_strategy is blank to prevent glance::api from including
    # ::glance::api::authtoken.
    auth_strategy                => '',
    database_connection          => $database_connection,
    enable_proxy_headers_parsing => $confhaproxy,
    stores                       => ['glance.store.rbd.Store'],
    os_region_name               => $region,
    show_image_direct_url        => true,
    show_multiple_locations      => true,
    sync_db                      => $db_sync,
  }

  class { '::glance::api::authtoken':
    password             => $keystone_password,
    auth_url             => "${keystone_internal}:5000",
    www_authenticate_uri => "${keystone_public}:5000",
    memcached_servers    => $memcache,
    region_name          => $region,
  }

  glance_api_config {
    'DEFAULT/default_store':          value => 'rbd';
    'image_format/container_formats': value => $container_formats_real;
    'image_format/disk_formats':      value => $disk_formats_real;
  }

  if ($upload_mode == 'direct') {
    glance_api_config {
      'cors/allowed_origin': value => $horizon_url;
      'cors/max_age':        value => 3600;
      'cors/allow_methods':  value => 'GET,PUT,POST,DELETE';
    }
  }
}
