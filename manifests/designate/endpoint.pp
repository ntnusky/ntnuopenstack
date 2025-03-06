# Configures the endpoint and keystone user for designate
define ntnuopenstack::designate::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::designate::deps

  Keystone::Resource::Service_identity["designate-${region}"]
  -> Anchor['designate::service::end']

  keystone::resource::service_identity { "designate-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'dns',
    service_description => 'DNS as a Service',
    service_name        => 'designate',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'designate@localhost',
    tenant              => 'services',
    roles               => ['admin'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:9001",
    admin_url           => "${adminurl}:9001",
    internal_url        => "${internalurl}:9001",
  }
}

