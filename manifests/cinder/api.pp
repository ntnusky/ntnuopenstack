# Installs and configures the cinder API
class ntnuopenstack::cinder::api {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'default_value' => true,
    'value_type'    => Boolean,
  })
  $db_sync = lookup('ntnuopenstack::cinder::db::sync', Boolean)

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::cinder::base
  contain ::ntnuopenstack::cinder::firewall::server
  include ::profile::services::memcache::pythonclient

  if($confhaproxy) {
    contain ::ntnuopenstack::cinder::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::cinder::api':
    enabled                      => false,
    service_name                 => 'httpd',
    default_volume_type          => 'Normal',
    enable_proxy_headers_parsing => $confhaproxy,
    sync_db                      => $db_sync,
  }

  class { '::cinder::wsgi::apache':
    ssl               => false,
    access_log_format => $logformat,
  }
}
