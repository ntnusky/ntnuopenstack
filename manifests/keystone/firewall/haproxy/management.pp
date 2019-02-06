# Configures the firewall to allow regular keystone from the infra-net, and
# keystone-admin from all the management networks. 
class ntnuopenstack::keystone::firewall::haproxy::management {
  require ::profile::baseconfig::firewall

  $infra4_net = lookup('profile::networks::management::ipv4::prefix', {
    'value_type'    => Variant[Boolean, Stdlib::IP::Address::V4::CIDR],
    'default_value' => false,
  })
  $mgmt4_nets = lookup('profile::networking::management::ipv4::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V4::CIDR],
    'default_value' => [],
    'merge'         => 'unique',
  })

  $infra6_net = lookup('profile::networks::management::ipv6::prefix', {
    'value_type'    => Variant[Boolean, Stdlib::IP::Address::V6::CIDR],
    'default_value' => false,
  })
  $mgmt6_nets = lookup('profile::networking::management::ipv6::prefixes', {
    'value_type'    => Array[Stdlib::IP::Address::V6::CIDR],
    'default_value' => [],
    'merge'         => 'unique',
  })

  if($infra4_net) {
    firewall { '100 Keystone API - Internal':
      proto  => 'tcp',
      dport  => 5000,
      action => 'accept',
      source => $infra4_net,
    }
  }

  $mgmt4_nets.each | $net | {
    firewall { "100 Keystone API - Admin from ${net}":
      proto  => 'tcp',
      dport  => 35357,
      action => 'accept',
      source => $net,
    }
  }

  if($infra6_net) {
    firewall { '100 Keystone API v6 - Internal':
      proto    => 'tcp',
      dport    => 5000,
      action   => 'accept',
      source   => $infra6_net,
      provider => 'ip6tables',
    }
  }

  $mgmt6_nets.each | $net | {
    firewall { "100 Keystone API - Admin from ${net}":
      proto    => 'tcp',
      dport    => 35357,
      action   => 'accept',
      source   => $net,
      provider => 'ip6tables',
    }
  }
}
