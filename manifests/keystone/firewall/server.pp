# Configures the firewall for the keystone server
#  - We basicly only allow our management-network to use keystone, as the rest
#    of the traffic will enter trough the loadbalancers.
class ntnuopenstack::keystone::firewall::server {
  $common = lookup('ntnuopenstack::keystone::interregional', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  if($common) {
    ::profile::firewall::infra::all { 'Keystone-API':
      port => 5000,
    }
  } else {
    ::profile::firewall::infra::region { 'Keystone-API':
      port => 5000,
    }
  }

}
