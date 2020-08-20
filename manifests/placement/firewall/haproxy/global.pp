# Configures the firewall to accept incoming traffic to the placement API.
class ntnuopenstack::placement::firewall::haproxy::global {
  ::profile::baseconfig::firewall::service::global { 'Placement':
    protocol => 'tcp',
    port     => 8778,
  }
}
