# Configures the neutron ml2 agent to use VXLAN for tenant traffic.
class ntnuopenstack::neutron::tenant::vxlan {
  $tenant_if = lookup('profile::interfaces::tenant')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::firewall::vxlan
  include ::ntnuopenstack::neutron::ml2::config
  require ::vswitch::ovs

  # Make sure there is allways an IP available for tunnel endpoints, even if the
  # correct IP is not present yet.
  if(has_key($facts['networking']['interfaces'], 'br-provider')) {
    $local_ip = pick(
      $facts['networking']['interfaces']['br-provider']['ip'],
      '169.254.254.254'
    )
  } else {
    $local_ip = '169.254.254.254'
  }

  class { '::ntnuopenstack::neutron::ovs':
    tenant_mapping => 'provider:br-provider',
    local_ip       => $local_ip,
    tunnel_types   => ['vxlan'],
  }

  # If the vxlan-endpoint is a VLAN on a physical interface, connect a patch
  # between the br-provider bridge, and a bridge called
  # 'br-vlan-${physical-if}'. The bridges are also created if they dont exist
  # from before.
  #
  # TODO: The 'vlan' option should be replaced with the more explicit 'vswitch'
  #       option.
  if($tenant_if == 'vlan') {
    $tenant_parent = lookup('profile::interfaces::tenant::parentif')
    $tenant_vlan = lookup('profile::interfaces::tenant::vlanid')

    $n = "${tenant_parent}-${tenant_vlan}-br-provider"
    ::profile::infrastructure::ovs::patch { $n :
      physical_if => $tenant_parent,
      vlan_id     => $tenant_vlan,
      ovs_bridge  => 'br-provider',
    }

  # If the vxlan-endpoint should be connected to a certain VLAN at an already
  # existing vswitch:
  } elsif ($tenant_if == 'vswitch') {
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
