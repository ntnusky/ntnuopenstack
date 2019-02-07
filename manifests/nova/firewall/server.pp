# Configures the firewall to accept incoming traffic to the nova API. 
class ntnuopenstack::nova::firewall::server {
  ::profile::baseconfig::firewall::service::infra { 'Nova-API':
    protocol => 'tcp',
    port     => 8774,
  }
  ::profile::baseconfig::firewall::service::infra { 'Nova-Metadata':
    protocol => 'tcp',
    port     => 8775,
  }
  ::profile::baseconfig::firewall::service::infra { 'Nova-Placement':
    protocol => 'tcp',
    port     => 8778,
  }

  firewall { '511 nova-api-INPUT':
    jump  => 'nova-api-INPUT',
    proto => 'all',
  }
}
