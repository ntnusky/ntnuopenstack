# Installs the heat API
class ntnuopenstack::heat::api {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::heat::base
  require ::ntnuopenstack::heat::firewall::api
  include ::ntnuopenstack::heat::logging::api
  require ::ntnuopenstack::repo

  if($confhaproxy) {
    contain ::ntnuopenstack::heat::haproxy::backend
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::heat::api':
    enabled      => false,
    service_name => 'httpd',
  }

  class { '::heat::api_cfn':
    enabled      => false,
    service_name => 'httpd',
  }

  class { '::heat::wsgi::apache_api':
    access_log_format => $logformat,
  }

  class { '::heat::wsgi::apache_api_cfn':
    access_log_format => $logformat,
  }
}
