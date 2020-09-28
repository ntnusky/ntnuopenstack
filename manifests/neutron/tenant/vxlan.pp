# Configures the neutron ml2 agent to use VXLAN for tenant traffic.
class ntnuopenstack::neutron::tenant::vxlan {
  $tenant_if = lookup('profile::interfaces::tenant')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::firewall::vxlan
  include ::ntnuopenstack::neutron::ml2::config
  require ::vswitch::ovs

  if($tenant_if == 'vswitch') {
    $managevswitch = false
    ::profile::infrastructure::ovs::bridge { 'br-provider' : }
  } else {
    $managevswitch = true
  }

  # If the br-provider interface is in place, with an IP address, configure ovs
  # to use it as a VXLAN VTEP.
  if('br-provider' in $facts['networking']['interfaces'] and
      'ip' in $facts['networking']['interfaces']['br-provider']) {
    class { '::ntnuopenstack::neutron::ovs':
      tenant_mapping => 'provider:br-provider',
      local_ip       => $facts['networking']['interfaces']['br-provider']['ip'],
      tunnel_types   => ['vxlan'],
      manage_vswitch => $managevswitch,
    }
  }

  # If the vxlan-endpoint should be connected to a certain VLAN at an already
  # existing vswitch:
  if ($tenant_if == 'vswitch') {
    $bridge = lookup('ntnuopenstack::tenant::bridge', String)
    $vlan = lookup('ntnuopenstack::tenant::vlan', Integer)

    ::profile::infrastructure::ovs::patch::vlan { "br-provider to ${bridge}":
      source_bridge      => $bridge,
      source_vlan        => $vlan,
      destination_bridge => 'br-provider',
    }

  # If the vxlan-endpoint is a physical interface, connect br-provider to that
  # interface.
  } else {
    vs_port { $tenant_if:
      ensure => present,
      bridge => 'br-provider',
    }
  }
}
