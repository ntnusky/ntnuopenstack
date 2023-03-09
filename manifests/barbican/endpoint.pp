# Configure the endpoint and keystone user for barbican
class ntnuopenstack::barbican::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::barbican::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::barbican::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::barbican::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::barbican::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $admin    = "${endpoint_admin}:9311"
  $internal = "${endpoint_internal}:9311"
  $public   = "${endpoint_public}:9311"

  class { 'barbican::keystone::auth':
    admin_url    => $admin,
    internal_url => $internal,
    password     => $keystone_password,
    public_url   => $public,
    region       => $region,
  }
}

