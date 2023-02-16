# Configures nova's authtoken 
class ntnuopenstack::nova::auth {
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')
  $nova_password = lookup('ntnuopenstack::nova::keystone::password')
  $region = lookup('ntnuopenstack::region')

  ::ntnuopenstack::common::authtoken { 'nova': }

  class { '::nova::keystone':
    auth_url    => "${internal_endpoint}:5000/",
    password    => $nova_password,
    region_name => $region,
    username    => 'nova',
  }
}
