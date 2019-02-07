# Installs the heat API
class ntnuopenstack::heat::api {
  $confhaproxy = lookup('ntnuopenstack::haproxy::configure::backend', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  require ::ntnuopenstack::heat::base
  require ::ntnuopenstack::heat::firewall::api
  require ::ntnuopenstack::repo

  if($confhaproxy) {
    contain ::ntnuopenstack::heat::haproxy::backend
  }

  class { '::heat::api' : }
  class { '::heat::api_cfn' : }
}
