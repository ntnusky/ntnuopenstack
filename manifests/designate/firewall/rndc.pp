# Configures firewall rules for rndc to Designate NS servers
class ntnuopenstack::designate::firewall::rndc {
  ::profile::baseconfig::firewall::service::infra { 'designate rndc':
    protocol => 'tcp',
    port     => 953,
  }
}
