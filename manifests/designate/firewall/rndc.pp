# Configures firewall rules for rndc to Designate NS servers
class ntnuopenstack::designate::firewall::rndc {
  ::profile::firewall::custom { 'designate rndc':
    hiera_key => 'ntnuopenstack::designate::api_servers',
    transport_protocol  => 'tcp',
    port      => 953,
  }
}
