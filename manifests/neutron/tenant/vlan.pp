# Configures neutron to use VLAN's for tenant networks
class ntnuopenstack::neutron::tenant::vlan {
  $tenant_if = lookup('profile::interfaces::tenant')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::ml2::config
  require ::vswitch::ovs

  # If the tenant-vlans are configured to be present on a VLAN, print an error.
  if($tenant_if == 'vlan') {
    $a = 'It is impossible to use a VLAN for tenant_if when using VLANs to'
    $b = 'separate tenant networks.'
    fail("${a} ${b}")

  # If the tenant-vlans are connected to a vswitch which already exists, connect
  # to that vswitch.
  } elsif ($tenant_if == 'vswitch') {
    $tenant_bridge = lookup('ntnuopenstack::tenant::bridge')

    class { '::ntnuopenstack::neutron::ovs':
      tenant_mapping => "physnet-vlan:${tenant_bridge}",
    }

  # If the tenant-VLANS are connected to a physical if; create the bridge
  # 'br-vlan' and add the physical interface to it.
  } else {
    class { '::ntnuopenstack::neutron::ovs':
      tenant_mapping => 'physnet-vlan:br-vlan',
    }

    vs_port { $tenant_if:
      ensure => present,
      bridge => 'br-vlan',
    }
  }
}
