# Installs and configures Placement API
class ntnuopenstack::nova::endpoint::placement {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $password = lookup('ntnuopenstack::nova::placement::keystone::password', String)

  # Determine the endpoint addresses
  $nova_admin    = lookup('ntnuopenstack::nova::endpoint::admin',
                                Stdlib::Httpurl)
  $nova_internal = lookup('ntnuopenstack::nova::endpoint::internal',
                                Stdlib::Httpurl)

  class { '::nova::keystone::auth_placement':
    password     => $password,
    public_url   => "${nova_internal}:8778/placement",
    internal_url => "${nova_internal}:8778/placement",
    admin_url    => "${nova_admin}:8778/placement",
    region       => $region,
  }
}
