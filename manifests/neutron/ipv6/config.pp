# Configures neutron to allow IPv6 delegation to tenant subnets trough dhcpv6-pd
class ntnuopenstack::neutron::ipv6::config {
  neutron_config {
    'DEFAULT/ipv6_pd_enabled': value => 'True';
  }
}
