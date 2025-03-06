# Configures firewall rules for publishing nameservers
class ntnuopenstack::designate::firewall::dns {
  ::profile::firewall::global { 'designate publishing DNS server (TCP)':
    transport_protocol => 'tcp',
    port     => 53,
  }

  ::profile::firewall::global { 'designate publishing DNS server (UDP)':
    transport_protocol => 'udp',
    port     => 53,
  }
}
