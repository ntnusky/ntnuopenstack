# Configures novas connection to cinder
class ntnuopenstack::nova::common::cinder {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $region = lookup('ntnuopenstack::region', String)
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')

  require ::ntnuopenstack::repo

  class { '::nova::cinder':
    auth_url       => $auth_url,
    password       =>
      $services[$region]['services']['neutron']['keystone']['password'],
    os_region_name => $region,
    username       =>
      $services[$region]['services']['neutron']['keystone']['username'],
  }
}
