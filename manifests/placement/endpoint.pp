# Installs and configures Placement API
class ntnuopenstack::placement::endpoint {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $password = lookup('ntnuopenstack::placement::keystone::password', String)

  $standalone = lookup('ntnuopenstack::placement::standalone',
                          Boolean, 'first', false)

  if($standalone) {
    # Determine the endpoint addresses
    $placement_admin    = lookup('ntnuopenstack::placement::endpoint::admin',
                                  Stdlib::Httpurl)
    $placement_internal = lookup('ntnuopenstack::placement::endpoint::internal',
                                  Stdlib::Httpurl)
    $placement_public   = lookup('ntnuopenstack::placement::endpoint::public',
                                  Stdlib::Httpurl)
    $public   = "${placement_public}:8778/placement"
    $internal = "${placement_internal}:8778/placement"
    $admin    = "${placement_admin}:8778/placement"
  } else {
    # Determine the endpoint addresses
    $nova_admin    = lookup('ntnuopenstack::nova::endpoint::admin',
                                  Stdlib::Httpurl)
    $nova_internal = lookup('ntnuopenstack::nova::endpoint::internal',
                                  Stdlib::Httpurl)

    $public   = "${nova_internal}:8778/placement"
    $internal = "${nova_internal}:8778/placement"
    $admin    = "${nova_admin}:8778/placement"
  }

  class { '::placement::keystone::auth':
    password     => $password,
    public_url   => $public,
    internal_url => $internal,
    admin_url    => $admin,
    region       => $region,
  }
}
