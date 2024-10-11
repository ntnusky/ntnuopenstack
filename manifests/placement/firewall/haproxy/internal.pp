# Configures the firewall to accept incoming traffic to the placement API. 
class ntnuopenstack::placement::firewall::haproxy::internal {
  ::profile::firewall::infra::region { 'Placement':
    port => 8778,
  }
}
