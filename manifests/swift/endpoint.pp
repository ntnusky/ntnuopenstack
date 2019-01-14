# Configures the endpoint and keystone user for swift
class ntnuopenstack::swift::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')
  $region = hiera('ntnuopenstack::region')

  keystone::resource::service_identity { 'swift':
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    service_type        => 'object-store',
    service_description => 'Openstack Object-Store Service',
    service_name        => 'swift',
    auth_name           => 'swift',
    region              => $region,
    password            => $keystone_password,
    email               => 'swift@localhost',
    tenant              => 'services',
    public_url          => "${endpoint_public}/v1/AUTH_%(tenant_id)s",
    admin_url           => "${endpoint_admin}:8080",
    internal_url        => "${endpoint_internal}:8080/v1/AUTH_%(tenant_id)s",
  }
}
