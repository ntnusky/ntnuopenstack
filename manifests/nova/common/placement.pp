# Configures nova to use the placement service 
class ntnuopenstack::nova::common::placement {
  $keystone = lookup('ntnuopenstack::endpoint::admin')
  $password = lookup('ntnuopenstack::placement::keystone::password')
  $region = lookup('ntnuopenstack::region')

  class { '::nova::placement':
    password    => $password,
    auth_url    => "${keystone}:5000/v3",
    region_name => $region,
  }
}
