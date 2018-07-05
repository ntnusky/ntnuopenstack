# Registers the nova api endpoint in keystone
class ntnuopenstack::nova::endpoint::api {
  $nova_password = hiera('ntnuopenstack::nova::keystone::password')
  $region = hiera('ntnuopenstack::region')

  $nova_public_ip = hiera('profile::api::nova::public::ip', '127.0.0.1')
  $nova_admin_ip = hiera('profile::api::nova::admin::ip', '127.0.0.1')
  $keystone_public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')
  $keystone_admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')

  $admin_endpoint = hiera('ntnuopenstack::endpoint::admin', undef)
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', undef)
  $public_endpoint = hiera('ntnuopenstack::endpoint::public', undef)

  $nova_admin    = pick($admin_endpoint, "http://${nova_admin_ip}")
  $nova_internal = pick($internal_endpoint, "http://${nova_admin_ip}")
  $nova_public   = pick($public_endpoint, "http://${nova_public_ip}")

  require ::ntnuopenstack::repo

  class { '::nova::keystone::auth':
    password     => $nova_password,
    public_url   => "${nova_public}:8774/v2.1",
    internal_url => "${nova_internal}:8774/v2.1",
    admin_url    => "${nova_admin}:8774/v2.1",
    region       => $region,
  }
}
