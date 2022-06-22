# Installs and configures the glance API
class ntnuopenstack::glance::api {
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

  $disk_formats = lookup('ntnuopenstack::glance::disk_formats', {
    'value_type'    => Hash[String, String],
    'default_value' => {'raw' => '', 'qcow2' => ''}
  })
  $container_formats = lookup('ntnuopenstack::glance::container_formats', {
    'value_type'    => Array[String],
    'default_value' => ['bare'],
  })

  require ::ntnuopenstack::repo
  contain ::ntnuopenstack::glance::ceph
  include ::ntnuopenstack::glance::dbconnection
  contain ::ntnuopenstack::glance::firewall::server::api
  include ::ntnuopenstack::glance::horizon
  include ::ntnuopenstack::glance::sudo
  include ::ntnuopenstack::glance::rabbit
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
    default_backend              => 'ceph-default',
    container_formats            => $container_formats,
    disk_formats                 => keys($disk_formats),
    enabled_backends             => ['ceph-default:rbd'],
    enable_proxy_headers_parsing => $confhaproxy,
    show_image_direct_url        => true,
    show_multiple_locations      => true,
    sync_db                      => $db_sync,
    worker_self_reference_url    => "http://${::fqdn}:9292",
  }

  class { '::glance::api::authtoken':
    password             => $keystone_password,
    auth_url             => "${keystone_internal}:5000",
    www_authenticate_uri => "${keystone_public}:5000",
    memcached_servers    => $memcache,
    region_name          => $region,
  }
}
