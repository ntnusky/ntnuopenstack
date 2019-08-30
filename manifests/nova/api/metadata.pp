# Installs nova-metadata as WSGI in apache
class ntnuopenstack::nova::api::metadata {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $neutron_secret = lookup('ntnuopenstack::nova::sharedmetadataproxysecret')

  if($confhaproxy) {
    contain ::ntnuopenstack::haproxy::backend::metadata
    $header_parsing = true
    $logformat = 'forwarded'
  } else {
    $header_parsing = false
    $logformat = false
  }

  class { '::nova::metadata':
    enable_proxy_headers_parsing         => $header_parsing,
    neutron_metadata_proxy_shared_secret => $neutron_secret,
  }

  class { '::nova::wsgi::apache_metadata':
    access_log_format => $logformat,
    ssl               => false,
  }
}


