# Configures the base cinder config
class ntnuopenstack::cinder::auth {
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $password = lookup('ntnuopenstack::cinder::keystone::password')
  $region_name = lookup('ntnuopenstack::region')

  ::ntnuopenstack::common::authtoken { 'cinder': }

  class { '::cinder::keystone::service_user':
    auth_url    => $auth_url,
    password    => $password,
    region_name => $region_name,
  }
}
