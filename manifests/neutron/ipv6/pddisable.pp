# This class disables the IPv6 pd implementation. We should use BGP instead.
# This class should be removed when upgrading to Train.
class ntnuopenstack::neutron::ipv6::pddisable {
  package { 'dibbler-client':
    ensure => 'absent',
  }
  neutron_config {
    'DEFAULT/ipv6_pd_enabled': ensure => 'absent';
  }
}
