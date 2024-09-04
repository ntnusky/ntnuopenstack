# Configures the endpoint and keystone user for swift
class ntnuopenstack::designate::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::designate::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::designate::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::designate::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::designate::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $admin = "${endpoint_admin}:9876"
  $public = "${endpoint_public}:9876"
  $internal = "${endpoint_internal}:9876"

  class { 'designate::keystone::auth':
    admin_url    => $admin,
    internal_url => $internal,
    password     => $keystone_password,
    public_url   => $public,
    region       => $region,
  }
}
