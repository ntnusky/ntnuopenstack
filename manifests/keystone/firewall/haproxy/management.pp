# Configures the firewall to allow regular keystone from the infra-net, and
# keystone-admin from all the management networks. 
class ntnuopenstack::keystone::firewall::haproxy::management {
  ::profile::baseconfig::firewall::service::infra { 'Keystone-Internal':
    protocol => 'tcp',
    port     => 5000,
  }
  ::profile::baseconfig::firewall::service::management { 'Keystone-Admin':
    protocol => 'tcp',
    port     => 35357,
  }
}
