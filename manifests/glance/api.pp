# Installs and configures the glance API
class ntnuopenstack::glance::api {
  $db_sync = lookup('ntnuopenstack::glance::db::sync', Boolean)

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

  $use_keystone_limits = lookup('ntnuopenstack::glance::keystone::limits', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  require ::ntnuopenstack::glance::auth
  contain ::ntnuopenstack::glance::ceph
  include ::ntnuopenstack::glance::dbconnection
  contain ::ntnuopenstack::glance::firewall::server::api
  include ::ntnuopenstack::glance::horizon
  include ::ntnuopenstack::glance::quota
  include ::ntnuopenstack::glance::rabbit
  include ::ntnuopenstack::glance::sudo
  require ::ntnuopenstack::repo

  if($installmunin) {
    include ::profile::monitoring::munin::plugin::openstack::glance
  }

  # If this server should be placed behind haproxy, export a haproxy
  # configuration snippet.
  if($confhaproxy) {
    contain ::ntnuopenstack::glance::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
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
    service_name                 => 'httpd',
    show_image_direct_url        => true,
    show_multiple_locations      => true,
    sync_db                      => $db_sync,
    use_keystone_limits          => $use_keystone_limits,
    worker_self_reference_url    => "http://${::fqdn}:9292",
  }

  class { '::glance::wsgi::apache':
    access_log_format => $logformat,
    ssl               => false,
  }
}
