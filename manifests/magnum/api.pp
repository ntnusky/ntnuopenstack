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

  # This is a temporary hack while wait for a fix for this bug:
  #https://bugs.launchpad.net/puppet-magnum/+bug/1900813
  $auth_url = lookup('magnum::keystone::authtoken::auth_url')
  $password = lookup('magnum::keystone::authtoken::password')

  magnum_config {
    'keystone_auth/auth_url'            : value => $auth_url;
    'keystone_auth/username'            : value => 'magnum';
    'keystone_auth/password'            : value => $password, secret => true;
    'keystone_auth/project_name'        : value => 'Default';
    'keystone_auth/project_domain_name' : value => 'Default';
    'keystone_auth/user_domain_name'    : value => 'Default';
  }
}
