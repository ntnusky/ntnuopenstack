# Allow incoming VXLAN tunnels.
class ntnuopenstack::neutron::firewall::vxlan {
  $tenantnet = lookup('profile::networks::tenant::ipv4::prefix')

  profile::firewall::custom { 'VXLAN':
    port               => 4789,
    prefixes           => [ $tenantnet ], 
    transport_protocol => 'udp',
    # Is this always true?
    #interface          => 'br-provider',
  }
}
