# Registers the nova api endpoint in keystone
class ntnuopenstack::nova::endpoint::api {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $nova_password = lookup('ntnuopenstack::nova::keystone::password', String)

  # Determine the endpoint addresses
  $nova_admin    = lookup('ntnuopenstack::nova::endpoint::admin',
                                Stdlib::Httpurl)
  $nova_internal = lookup('ntnuopenstack::nova::endpoint::internal',
                                Stdlib::Httpurl)
  $nova_public   = lookup('ntnuopenstack::nova::endpoint::public',
                                Stdlib::Httpurl)

  require ::ntnuopenstack::repo

  class { '::nova::keystone::auth':
    admin_url    => "${nova_admin}:8774/v2.1",
    internal_url => "${nova_internal}:8774/v2.1",
    password     => $nova_password,
    public_url   => "${nova_public}:8774/v2.1",
    region       => $region,
    roles        => ['admin', 'service'],
  }
}
