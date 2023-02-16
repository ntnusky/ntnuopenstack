# Configures auth for neutron 
class ntnuopenstack::neutron::auth {
  $keystone_admin = lookup('ntnuopenstack::keystone::endpoint::admin', 
      Stdlib::Httpurl)
  $nova_password = lookup('ntnuopenstack::nova::keystone::password', String)
  $region = lookup('ntnuopenstack::region', String)

  include ::neutron::server::notifications

  ::ntnuopenstack::common::authtoken { 'neutron' : }

  class { '::neutron::server::notifications::nova':
    auth_url     => "${keystone_admin}:5000",
    password     => $nova_password,
    region_name  => $region,
  }
}
