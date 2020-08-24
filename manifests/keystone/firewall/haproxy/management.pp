# Configures the firewall to allow regular keystone from the infra-net
class ntnuopenstack::keystone::firewall::haproxy::management {
  ::profile::baseconfig::firewall::service::infra { 'Keystone-Internal':
    protocol => 'tcp',
    port     => 5000,
  }
}
