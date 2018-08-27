# This class installs dibbler-client, and the required config.
# Intended for neutron network nodes
class ntnuopenstack::neutron::ipv6::agent {
  include ::ntnuopenstack::neutron::ipv6::config

  package { 'dibbler-client':
    ensure => 'present',
  }
}
