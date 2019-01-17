# Configures the firewall to accept incoming traffic to the swift API. 
class ntnuopenstack::swift::firewall::haproxy {
  require ::profile::baseconfig::firewall

  $swiftname = lookup('ntnuopenstack::swift::dns::name', {
    'default_value' => False,
  })

  # If no name is set for swift, the service is placed under the regular API
  # endpoint at port 7480. If name is set swift is placed at port 80/443 under
  # the supplied name.
  if(! $swiftname) {
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
}
