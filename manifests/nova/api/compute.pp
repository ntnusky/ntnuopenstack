# Installs and configures the nova compute API.
class ntnuopenstack::nova::api::compute {
  $sync_db = lookup('ntnuopenstack::nova::db::sync', {
    'value_type'    => Boolean,
    'default_value' => false,   # One of your nodes need to have this key set to
                                # true to automaticly populate the databases.
  })

  include ::apache::mod::status
  require ::ntnuopenstack::nova::auth
  include ::ntnuopenstack::nova::common::cinder
  include ::ntnuopenstack::nova::common::neutron
  require ::ntnuopenstack::nova::dbconnection
  contain ::ntnuopenstack::nova::firewall::server
  contain ::ntnuopenstack::nova::haproxy::backend::api
  include ::ntnuopenstack::nova::quota
  require ::ntnuopenstack::nova::services::base
  require ::ntnuopenstack::repo

  class { '::nova::api':
    enabled                      => false,
    enable_proxy_headers_parsing => true,
    service_name                 => 'httpd',
    sync_db                      => $sync_db,
    sync_db_api                  => $sync_db,
  }

  class { '::nova::wsgi::apache_api':
    ssl               => false,
    access_log_format => 'forwarded',
  }
}
