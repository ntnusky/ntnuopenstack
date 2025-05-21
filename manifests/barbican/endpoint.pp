# Configure the endpoint and keystone user for barbican
define ntnuopenstack::barbican::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::barbican::deps

  Keystone::Resource::Service_identity["barbican-${region}"] -> Anchor['barbican::service::end']

  keystone::resource::service_identity { "barbican-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'key-manager',
    service_description => 'Key Management Service',
    service_name        => 'barbican',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'barbican@localhost',
    tenant              => 'services',
    roles               => ['admin', 'service'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:9311",
    admin_url           => "${adminurl}:9311",
    internal_url        => "${internalurl}:9311",
  }
}

