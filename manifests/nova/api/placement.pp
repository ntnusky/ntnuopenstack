# Installs and configures Placement API
class ntnuopenstack::nova::api::placement {
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)

  if($confhaproxy) {
    contain ::ntnuopenstack::nova::haproxy::backend::placement
  }

  class { '::nova::wsgi::apache_placement':
    api_port => 8778,
    ssl      => false,
  }
}
