# Configures neutron to use VLAN's for tenant networks
class ntnuopenstack::neutron::tenant::vlan {
  $tenant_if = lookup('profile::interfaces::tenant')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::ml2::config
  require ::vswitch::ovs

  if($tenant_if == 'vlan') {
    $a = 'It is impossible to use a VLAN for tenant_if when using VLANs to'
    $b = 'separate tenant networks.'
    fail("${a} ${b}")
  }

  class { '::ntnuopenstack::neutron::ovs':
    tenant_mapping => 'physnet-vlan:br-vlan',
  }

  vs_port { $tenant_if:
    ensure => present,
    bridge => 'br-vlan',
  }
}
