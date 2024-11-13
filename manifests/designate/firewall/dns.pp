# Configures firewall rules for publishing nameservers
class ntnuopenstack::designate::firewall::dns {
  ::profile::baseconfig::firewall::service::global { 'designate publishing DNS server (TCP)':
    protocol => 'tcp',
    port     => 53,
  }

  ::profile::baseconfig::firewall::service::global { 'designate publishing DNS server (UDP)':
    protocol => 'udp',
    port     => 53,
  }
}
