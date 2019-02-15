# Configures the firewall to pass incoming traffic to the neutron API.
class ntnuopenstack::neutron::firewall::api {
  ::profile::baseconfig::firewall::service::infra { 'Neutron-API':
    protocol => 'tcp',
    port     => 9696,
  }
}
