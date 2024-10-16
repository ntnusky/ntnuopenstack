# Configures the keystone endpoint for the cinder API
define ntnuopenstack::cinder::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  # Always configure the original user and user roles, as these
  # can be used by the v3 service.
  keystone::resource::service_identity { "cinder-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'block-storage',
    service_description => 'Openstack Block Storage Service',
    service_name        => 'cinder',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'cinder@localhost',
    tenant              => 'services',
    roles               => ['admin', 'service'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:8776/v3/%(tenant_id)s",
    admin_url           => "${adminurl}:8776/v3/%(tenant_id)s",
    internal_url        => "${internalurl}:8776/v3/%(tenant_id)s",
  }

  keystone::resource::service_identity { "cinderv3-${region}":
    configure_user      => false,
    configure_user_role => false,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'volumev3',
    service_description => 'Cinder Service v3',
    service_name        => 'cinderv3',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'cinderv3@localhost',
    tenant              => 'services',
    roles               => ['admin', 'service'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:8776/v3/%(tenant_id)s",
    admin_url           => "${adminurl}:8776/v3/%(tenant_id)s",
    internal_url        => "${internalurl}:8776/v3/%(tenant_id)s",
  }
}
