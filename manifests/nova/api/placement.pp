# Installs and configures Placement API
class ntnuopenstack::nova::api::placement {
  $placement_password = hiera('ntnuopenstack::nova::placement::keysone::password')
  $region = hiera('ntnuopenstack::region')
  $confhaproxy = hiera('ntnuopenstack::haproxy::configure::backend', true)

  $admin_endpoint = hiera('ntnuopenstack::endpoint::admin', undef)
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $keystone_admin    = pick($admin_endpoint, "http://${keystone_admin_ip}")

  if($confhaproxy) {
    contain ::ntnuopenstack::nova::haproxy::backend::placement
  }

  class { '::nova::placement':
    password       => $placement_password,
    auth_url       => "${keystone_admin}:35357/v3",
    os_region_name => $region,
  }

  class { '::nova::wsgi::apache_placement':
    api_port => 8778,
    ssl      => false,
  }
}
