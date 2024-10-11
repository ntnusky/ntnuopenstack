# Configures the firewall to pass incoming traffic to the neutron API.
class ntnuopenstack::neutron::firewall::api {
  ::profile::firewall::infra::region { 'Neutron-API':
    port     => 9696,
  }
}
