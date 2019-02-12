# Installs and configures Placement API
class ntnuopenstack::nova::api::placement {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  if($confhaproxy) {
    contain ::ntnuopenstack::nova::haproxy::backend::placement
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::nova::wsgi::apache_placement':
    api_port          => 8778,
    ssl               => false,
    access_log_format => $logformat,
  }
}
