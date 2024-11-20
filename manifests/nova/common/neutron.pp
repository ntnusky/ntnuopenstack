# Configures nova to use neutron for networking.
class ntnuopenstack::nova::common::neutron {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $region = lookup('ntnuopenstack::region', String)
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')

  $floating_pool = lookup('ntnuopenstack::neutron::default::floatingpool', {
    'default_value' => 'ntnu-internal',
    'value_type'    => String,
  })

  require ::ntnuopenstack::repo

  class { '::nova::network::neutron':
    auth_url              => $auth_url, 
    default_floating_pool => $floating_pool,
    password              => 
      $services[$region]['services']['neutron']['keystone']['password'],
    region_name           => $region,
    username              =>
      $services[$region]['services']['neutron']['keystone']['username'],
  }
}
