# Configures neutron for the appropriate tenant network strategy
class ntnuopenstack::neutron::tenant {
  $strategy = lookup('ntnuopenstack::neutron::tenant::isolation::type', {
    'value_type' => Enum['vlan', 'vxlan', 'combo']
  })
  $tenant_if = lookup('profile::interfaces::tenant')

  require ::ntnuopenstack::repo
  require ::ntnuopenstack::neutron::base
  include ::ntnuopenstack::neutron::ml2::config
  require ::vswitch::ovs

  if($tenant_if == 'vswitch') {
    $tenant_bridge = lookup('ntnuopenstack::tenant::bridge')
    $manage_vswitch = false

    if ($strategy == 'vlan') {
      $tenant_mapping = "physnet-vlan:${tenant_bridge}"
    } elsif ($strategy in ['vxlan', 'combo']) {
      $vlan = lookup('ntnuopenstack::tenant::vlan', Integer)

      if($strategy == 'vxlan') {
        $tenant_mapping = 'provider:br-provider'
      } else {
        $tenant_mapping = [
          'provider:br-provider',
          "physnet-vlan:${tenant_bridge}",
        ]
      }

      ::profile::infrastructure::ovs::patch::vlan { "br-provider to ${tenant_bridge}":
        source_bridge      => $tenant_bridge,
        source_vlan        => $vlan,
        destination_bridge => 'br-provider',
      }
    }
  } else {
    $manage_vswitch = true

    if ($strategy == 'vlan') {
      vs_port { $tenant_if:
        ensure => present,
        bridge => 'br-vlan',
      }
      $tenant_bridge = 'br-vlan'
      $provider = 'physnet-vlan'
    } elsif ($strategy == 'vxlan') {
      include ::ntnuopenstack::neutron::firewall::vxlan
      vs_port { $tenant_if:
        ensure => present,
        bridge => 'br-provider',
      }
      $tenant_bridge = 'br-provider'
      $provider = 'provider'
    } else ($strategy == 'combo') {
      fail('Both VLAN and VXLAN tenant networks requires explicit ovs config')
    }
    $tenant_mapping = "${provider}:${tenant_bridge}"
  }

  if('br-provider' in $facts['networking']['interfaces'] and
      'ip' in $facts['networking']['interfaces']['br-provider']) {
    $local_ip = $facts['networking']['interfaces']['br-provider']['ip']
  } else {
    $local_ip = undef
  }

  class { '::ntnuopenstack::neutron::ovs':
    manage_vswitch => $manage_vswitch,
    tenant_mapping => $tenant_mapping,
    local_ip       => $local_ip,
    tunnel_types   => $strategy in ['vxlan','common'] ? {
                            true => ['vxlan'], default => undef, },
  }
}
