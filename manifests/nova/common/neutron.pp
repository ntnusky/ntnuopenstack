# Configures nova to use neutron for networking.
class ntnuopenstack::nova::common::neutron {
  $region = lookup('ntnuopenstack::region', String)
  $neutron_password = lookup('ntnuopenstack::neutron::keystone::password', String)

  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
                                Stdlib::Httpurl)
  $neutron_internal = lookup('ntnuopenstack::neutron::endpoint::internal',
                                Stdlib::Httpurl)

  $floating_pool = lookup('ntnuopenstack::neutron::default::floatingpool', {
    'default_value' => 'ntnu-internal',
    'value_type'    => String,
  })

  require ::ntnuopenstack::repo

  class { '::nova::network::neutron':
    auth_url              => "${keystone_internal}:5000/v3",
    default_floating_pool => $floating_pool,
    password              => $neutron_password,
    region_name           => $region,
  }
}
