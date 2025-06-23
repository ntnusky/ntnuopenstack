# Installs and configures Placement API
class ntnuopenstack::placement::api {
  $db_sync = lookup('ntnuopenstack::placement::db::sync', Boolean)
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  include ::apache::mod::status
  require ::ntnuopenstack::repo
  include ::ntnuopenstack::placement::auth
  include ::ntnuopenstack::placement::dbconnection
  include ::ntnuopenstack::placement::firewall::server

  # Placement logs all activity through apache-logs.
  include ::profile::services::apache::logging

  if($confhaproxy) {
    contain ::ntnuopenstack::placement::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::placement':
    sync_db => $db_sync,
  }

  class { '::placement::api':
    api_service_name             => 'httpd',
    enable_proxy_headers_parsing => $confhaproxy,
    sync_db                      => $db_sync,
  }

  class { '::placement::wsgi::apache':
    access_log_format => $logformat,
    path              => '/placement',
    port              => 8778,
    ssl               => false,
  }
}
