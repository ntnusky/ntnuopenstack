# Configures the firewall to accept incoming traffic to the placement API. 
class ntnuopenstack::placement::firewall::haproxy::internal {
  ::profile::baseconfig::firewall::service::infra { 'Placement':
    protocol => 'tcp',
    port     => 8778,
  }
}
