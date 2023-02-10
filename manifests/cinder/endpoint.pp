# Configures the keystone endpoint for the cinder API
class ntnuopenstack::cinder::endpoint {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $keystone_password = lookup('ntnuopenstack::cinder::keystone::password',
                                String)

  # Determine the endpoint addresses
  $cinder_admin    = lookup('ntnuopenstack::cinder::endpoint::admin',
                                Stdlib::Httpurl)
  $cinder_internal = lookup('ntnuopenstack::cinder::endpoint::internal',
                                Stdlib::Httpurl)
  $cinder_public   = lookup('ntnuopenstack::cinder::endpoint::public',
                                Stdlib::Httpurl)

  require ::ntnuopenstack::repo

  class  { '::cinder::keystone::auth':
    admin_url_v3    => "${cinder_admin}:8776/v3/%(tenant_id)s",
    internal_url_v3 => "${cinder_internal}:8776/v3/%(tenant_id)s",
    password        => $keystone_password,
    public_url_v3   => "${cinder_public}:8776/v3/%(tenant_id)s",
    region          => $region,
    system_roles    => [ 'reader' ],
    system_roles_v3 => [ 'reader' ],
  }
}
