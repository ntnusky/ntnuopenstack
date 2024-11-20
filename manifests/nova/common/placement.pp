# Configures nova to use the placement service 
class ntnuopenstack::nova::common::placement {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $region = lookup('ntnuopenstack::region')

  class { '::nova::placement':
    username    =>
      $services[$region]['services']['placement']['keystone']['username'],
    password    =>
      $services[$region]['services']['placement']['keystone']['password'],
    auth_url    => $auth_url, 
    region_name => $region,
  }
}
