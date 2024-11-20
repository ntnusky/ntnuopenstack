# Configures the firewall to allow regular keystone from the infra-net
class ntnuopenstack::keystone::firewall::haproxy::management {
  ::profile::firewall::infra::all { 'Keystone-Internal':
    port => 5000,
  }
}
