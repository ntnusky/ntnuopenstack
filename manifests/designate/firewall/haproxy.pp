# Configures the firewall to accept incoming traffic to the designate API.
class ntnuopenstack::designate::firewall::haproxy {
  $port = lookup('ntnuopenstack::designate::api::port')

  ::profile::baseconfig::firewall::service::global { 'Designate-API':
    protocol => 'tcp',
    port     => $port,
  }
}
