# Configures the firewall to accept incoming traffic to the placement API.
class ntnuopenstack::placement::firewall::server {
  ::profile::baseconfig::firewall::service::infra { 'Placement':
    protocol => 'tcp',
    port     => 8778,
  }
}
