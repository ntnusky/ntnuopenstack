# Configures the firewall to accept incoming traffic to the placement API.
class ntnuopenstack::placement::firewall::server {
  ::profile::firewall::infra::region { 'Placement':
    port => 8778,
  }
}
