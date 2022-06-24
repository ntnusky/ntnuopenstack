# Configure the endpoint and keystone user for magnum
class ntnuopenstack::magnum::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::magnum::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $admin    = "${endpoint_admin}:9511/v1"
  $internal = "${endpoint_internal}:9511/v1"
  $public   = "${endpoint_public}:9511/v1"

  class { 'magnum::keystone::auth':
    admin_url    => $admin,
    internal_url => $internal,
    password     => $keystone_password,
    public_url   => $public,
    region       => $region,
    system_roles => ['admin'],
  }
}

