# Installs the Magnum API
class ntnuopenstack::magnum::api {
  $sync_db = lookup('ntnuopenstack::magnum::db::sync', Boolean)

  require ::ntnuopenstack::magnum::base
  include ::ntnuopenstack::magnum::params
  include ::ntnuopenstack::magnum::clients
  include ::ntnuopenstack::magnum::firewall::api
  include ::ntnuopenstack::magnum::haproxy::backend
  include ::profile::monitoring::munin::plugin::openstack::magnum

  $package_ensure = $::ntnuopenstack::magnum::params::package_ensure

  class { '::magnum::api':
    enabled        => false,
    package_ensure => $package_ensure,
    service_name   => 'httpd',
    sync_db        => $sync_db,
    enabled_ssl    => false,
  }

  class { '::magnum::wsgi::apache':
    ssl               => false,
    access_log_format => 'forwarded',
  }
}
