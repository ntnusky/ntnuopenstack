# Configures the endpoint and keystone user for swift
class ntnuopenstack::octavia::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::octavia::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $admin = "${endpoint_admin}:9876"
  $public = "${endpoint_public}:9876"
  $internal = "${endpoint_internal}:9876"

  class { 'octavia::keystone::auth':
    password     => $keystone_password,
    region       => $region,
    public_url   => $public,
    admin_url    => $admin,
    internal_url => $internal,
  }
}
