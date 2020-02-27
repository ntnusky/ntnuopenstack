# Configure the endpoint and keystone user for barbican
class ntnuopenstack::barbican::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::barbican::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $admin    = "${endpoint_admin}:9311"
  $internal = "${endpoint_internal}:9311"
  $public   = "${endpoint_public}:9311"

  class { 'barbican::keystone::auth':
    password     => $keystone_password,
    region       => $region,
    admin_url    => $admin,
    internal_url => $internal,
    public_url   => $public,
  }
}

