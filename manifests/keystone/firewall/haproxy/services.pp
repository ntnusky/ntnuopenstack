# Opens the firewall for the keystone port from any source
class ntnuopenstack::keystone::firewall::haproxy::services {
  require ::profile::baseconfig::firewall

  firewall { '100 Keystone API - Public':
    proto  => 'tcp',
    dport  => 5000,
    action => 'accept',
  }
  firewall { '100 Keystone API - Public IPv6':
    proto    => 'tcp',
    dport    => 5000,
    action   => 'accept',
    provider => 'ip6tables',
  }
}
