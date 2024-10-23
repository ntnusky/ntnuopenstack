# Configures firewall rules to allow zone transfer to the outward facing authoritative nameservers
class ntnuopenstack::designate::firewall::dns {
  $transferSourceV4 = [
    '129.241.0.208/32', # ns1.ntnu.no
    '129.241.0.209/32', # ns2.ntnu.no
    '129.241.43.128/25', # admin-vlan543
  ]

  $transferSourceV6 = [
    '2001:700:300::208/128', # ns1.ntnu.no
    '2001:700:300::209/128', # ns2.ntnu.no
    '2001:700:300:9::/64', # admin-vlan543
  ]

  ::profile::baseconfig::firewall::service::custom { 'designate worker DNS zone transfer (TCP)':
    protocol => 'tcp',
    port     => 53,
    v4source => $transferSourceV4,
    v6source => $transferSourceV6,
  }

  ::profile::baseconfig::firewall::service::custom { 'designate worker DNS zone transfer (UDP)':
    protocol => 'udp',
    port     => 53,
    v4source => $transferSourceV4,
    v6source => $transferSourceV6,
  }
}
