# Allow incoming VXLAN tunnels.
class ntnuopenstack::neutron::firewall::vxlan {
  $tenantnet = lookup('profile::networks::tenant::ipv4::prefix', {
    'default_value' => undef, 
    'value_type'    => Optional[Variant[
      Stdlib::IP::Address::V4::CIDR,
      Stdlib::IP::Address::V6::CIDR,
    ]],
  })
  $tenantnet_new = lookup('ntnuopenstack::neutron::tenant::vxlan::network', {
    'default_value' => $tenantnet,
    'value_type'    => Variant[
      Stdlib::IP::Address::V4::CIDR,
      Stdlib::IP::Address::V6::CIDR,
    ],
  })

  profile::firewall::custom { 'VXLAN':
    port               => 4789,
    prefixes           => [ $tenantnet_new ], 
    transport_protocol => 'udp',
    # Is this always true?
    #interface          => 'br-provider',
  }
}
