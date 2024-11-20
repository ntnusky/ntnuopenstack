# Configures firewall rules for publishing nameservers
class ntnuopenstack::designate::firewall::dns {
  ::profile::firewall::global { 'designate publishing DNS server (TCP)':
    protocol => 'tcp',
    port     => 53,
  }

  ::profile::firewall::global { 'designate publishing DNS server (UDP)':
    protocol => 'udp',
    port     => 53,
  }
}
