# Configures the firewall to accept incoming traffic to the nova API. 
class ntnuopenstack::nova::firewall::haproxy {
  ::profile::baseconfig::firewall::service::global { 'Nova-API':
    protocol => 'tcp',
    port     => 8774,
  }
  ::profile::baseconfig::firewall::service::global { 'Nova-Metadata':
    protocol => 'tcp',
    port     => 8775,
  }
  ::profile::baseconfig::firewall::service::global { 'Nova-Placement':
    protocol => 'tcp',
    port     => 8778,
  }
  ::profile::baseconfig::firewall::service::global { 'Nova-VNCProxy':
    protocol => 'tcp',
    port     => 6080,
  }
}
