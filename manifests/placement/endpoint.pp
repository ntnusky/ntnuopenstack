# Configures the placement API endpoint in keystone 
class ntnuopenstack::placement::endpoint {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $password = lookup('ntnuopenstack::placement::keystone::password', String)

  # Determine the endpoint addresses
  $placement_admin    = lookup('ntnuopenstack::placement::endpoint::admin',
                                Stdlib::Httpurl)
  $placement_internal = lookup('ntnuopenstack::placement::endpoint::internal',
                                Stdlib::Httpurl)
  $placement_public   = lookup('ntnuopenstack::placement::endpoint::public',
                                Stdlib::Httpurl)

  class { '::placement::keystone::auth':
    password     => $password,
    public_url   => "${placement_public}:8778/placement",
    internal_url => "${placement_internal}:8778/placement",
    admin_url    => "${placement_admin}:8778/placement",
    region       => $region,
  }
}
