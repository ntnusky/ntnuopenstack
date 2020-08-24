# This class configures the keystone authentication for octavia
class ntnuopenstack::octavia::auth {
  $keystone_password = lookup('ntnuopenstack::octavia::keystone::password')
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')

  require ::ntnuopenstack::repo

  class { '::octavia::service_auth':
    auth_url            => "${internal_endpoint}:5000/v3",
    username            => 'octavia',
    project_name        => 'services',
    password            => $keystone_password,
    user_domain_name    => 'default',
    project_domain_name => 'default',
    auth_type           => 'password',
  }
}
