# Registers the glance endpoint in keystone
class ntnuopenstack::glance::endpoint {
  $region = hiera('profile::region')
  $keystone_password = hiera('profile::glance::keystone::password')

  $admin_endpoint = hiera('profile::openstack::endpoint::admin', undef)
  $internal_endpoint = hiera('profile::openstack::endpoint::internal', undef)
  $public_endpoint = hiera('profile::openstack::endpoint::public', undef)

  $glance_admin_ip = hiera('profile::api::glance::admin::ip', '127.0.0.1')
  $glance_public_ip = hiera('profile::api::glance::public::ip', '127.0.0.1')

  $glance_admin    = pick($admin_endpoint, "http://${glance_admin_ip}")
  $glance_internal = pick($internal_endpoint, "http://${glance_admin_ip}")
  $glance_public   = pick($public_endpoint, "http://${glance_public_ip}")

  class  { '::glance::keystone::auth':
    password     => $keystone_password,
    public_url   => "${glance_public}:9292",
    internal_url => "${glance_internal}:9292",
    admin_url    => "${glance_admin}:9292",
    region       => $region,
  }
}
