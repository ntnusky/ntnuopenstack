# Configures the firewall for the keystone server
#  - We basicly only allow our management-network to use keystone, as the rest
#    of the traffic will enter trough the loadbalancers.
class ntnuopenstack::keystone::firewall::server {
  ::profile::baseconfig::firewall::service::infra { 'Keystone-API':
    protocol => 'tcp',
    port     => [5000,35357],
  }
}
