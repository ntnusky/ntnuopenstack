# Installs and configures a neutron network node
class ntnuopenstack::neutron::network {

  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  require ::ntnuopenstack::repo

  contain ::ntnuopenstack::neutron::agents
  contain ::ntnuopenstack::neutron::base
  contain ::ntnuopenstack::neutron::external
  include ::ntnuopenstack::neutron::logging::net
  include ::ntnuopenstack::neutron::nolbaas
  contain ::ntnuopenstack::neutron::tenant

  if($installmunin) {
    contain ::profile::monitoring::munin::plugin::openstack::neutronnet
  }
}
