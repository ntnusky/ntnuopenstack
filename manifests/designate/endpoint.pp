# Configures the endpoint and keystone user for designate
class ntnuopenstack::designate::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::designate::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::designate::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::designate::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::designate::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $admin = "${endpoint_admin}:9001"
  $public = "${endpoint_public}:9001"
  $internal = "${endpoint_internal}:9001"

  class { '::designate::keystone::auth':
    admin_url    => $admin,
    internal_url => $internal,
    password     => $keystone_password,
    public_url   => $public,
    region       => $region,
  }
}
