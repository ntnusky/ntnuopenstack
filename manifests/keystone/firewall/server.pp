# Configures the firewall for the keystone server
#  - We basicly only allow our management-network to use keystone, as the rest
#    of the traffic will enter trough the loadbalancers.
class ntnuopenstack::keystone::firewall::server {
  ::profile::firewall::infra::region { 'Keystone-API':
    port => 5000,
  }
}
