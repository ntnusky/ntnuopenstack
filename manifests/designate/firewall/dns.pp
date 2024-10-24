# Configures firewall rules for the designate workers outward facing DNS
class ntnuopenstack::designate::firewall::dns {
  ::profile::baseconfig::firewall::service::global { 'designate worker outward facing DNS(TCP)':
    protocol => 'tcp',
    port     => 53,
  }

  ::profile::baseconfig::firewall::service::global { 'designate worker outward facing DNS(UDP)':
    protocol => 'udp',
    port     => 53,
  }
}
