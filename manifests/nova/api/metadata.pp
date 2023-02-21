# Installs nova-metadata as WSGI in apache
class ntnuopenstack::nova::api::metadata {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })
  $neutron_secret = lookup('ntnuopenstack::nova::sharedmetadataproxysecret')

  require ::ntnuopenstack::nova::services::base
  require ::ntnuopenstack::nova::dbconnection

  if($confhaproxy) {
    contain ::ntnuopenstack::nova::haproxy::backend::metadata
    $logformat = 'forwarded'
  } else {
    $logformat = false
  }

  class { '::nova::metadata':
    neutron_metadata_proxy_shared_secret => $neutron_secret,
  }

  class { '::nova::wsgi::apache_metadata':
    access_log_format => $logformat,
    ssl               => false,
  }
}


