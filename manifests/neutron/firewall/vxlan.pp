# Allow incoming VXLAN tunnels.
class ntnuopenstack::neutron::firewall::vxlan {
  $tenantnet = hiera('profile::networks::tenant::ipv4::prefix')

  require ::profile::baseconfig::firewall

  firewall { '800 accept VXLAN':
    source => $tenantnet,
    proto  => 'udp',
    dport  => '4789',
    action => 'accept',
  }
}
