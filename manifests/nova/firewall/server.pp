# Configures the firewall to accept incoming traffic to the nova API. 
class ntnuopenstack::nova::firewall::server {
  ::profile::firewall::infra::region { 'Nova-API':
    port => 8774,
  }
  ::profile::firewall::infra::region { 'Nova-Metadata':
    port => 8775,
  }
  ::profile::firewall::infra::region { 'Nova-Placement':
    port => 8778,
  }
}
