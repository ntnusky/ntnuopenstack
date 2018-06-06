# Configures the neutron ml2 agent to use VXLAN for tenant traffic.
class ntnuopenstack::neutron::tenant::vxlan {
  $_tenant_if = hiera('profile::interfaces::tenant')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::ml2::config
  require ::vswitch::ovs

  # Make sure there is allways an IP available for tunnel endpoints, even if the
  # correct IP is not present yet.
  $local_ip = pick($::ipaddress_br_provider, '169.254.254.254')

  if($_tenant_if == 'vlan') {
    $tenant_parent = hiera('profile::interfaces::tenant::parentif')
    $tenant_vlan = hiera('profile::interfaces::tenant::vlanid')
    $tenant_if = "br-vlan-${tenant_parent}"
  } else {
    $tenant_if = $_tenant_if
  }

  class { '::ntnuopenstack::neutron::ovs':
    tenant_mapping => 'provider:br-provider',
    local_ip       => $local_ip,
    tunnel_types   => ['vxlan'],
  }

  if($_tenant_if == 'vlan') {
    $n = "${tenant_parent}-${tenant_vlan}-br-provider"
    ::profile::infrastructure::ovs::patch { $n :
      physical_if => $tenant_parent,
      vlan_id     => $tenant_vlan,
      ovs_bridge  => 'br-provider',
    }
  } else {
    vs_port { $tenant_if:
      ensure => present,
      bridge => 'br-provider',
    }
  }
}
