# Configures nova to use neutron for networking.
class ntnuopenstack::nova::neutron {
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
    default_floating_pool => $floating_pool,
    neutron_region_name   => $region,
    neutron_password      => $neutron_password,
    neutron_auth_url      => "${keystone_internal}:5000/v3",
    vif_plugging_is_fatal => false,
    vif_plugging_timeout  => '0',
  }
}
