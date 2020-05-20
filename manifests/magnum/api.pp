# Installs the Magnum API
class ntnuopenstack::magnum::api {
  $sync_db = lookup('ntnuopenstack::magnum::db::sync', Boolean)

  require ::ntnuopenstack::magnum::base
  include ::ntnuopenstack::magnum::clients
  include ::ntnuopenstack::magnum::firewall::api
  include ::ntnuopenstack::magnum::haproxy::backend
  include ::profile::monitoring::munin::plugin::openstack::magnum

  class { '::magnum::api':
    enabled        => false,
    package_ensure => 'absent',
    service_name   => 'httpd',
    sync_db        => $sync_db,
    enabled_ssl    => false,
  }

  class { '::magnum::wsgi::apache':
    ssl               => false,
    access_log_format => 'forwarded',
  }
}
