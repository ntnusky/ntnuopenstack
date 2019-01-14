# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::haproxy {
  require ::profile::baseconfig::firewall

  firewall { '500 accept IPv4 Swift API':
    proto  => 'tcp',
    dport  => '7480',
    action => 'accept',
  }

  firewall { '500 accept IPv6 Swift API':
    proto    => 'tcp',
    dport    => '7480',
    action   => 'accept',
    provider => 'ip6tables',
  }
}
