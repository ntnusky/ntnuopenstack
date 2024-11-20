# Configures the placement API endpoint in keystone 
define ntnuopenstack::placement::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::placement::deps

  Keystone::Resource::Service_identity["placement-${region}"] -> Anchor['placement::service::end']

  keystone::resource::service_identity { "placement-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'placement',
    service_description => 'OpenStack Placement Service',
    service_name        => 'placement',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'placement@localhost',
    tenant              => 'services',
    roles               => ['admin', 'service'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:8778/placement",
    admin_url           => "${adminurl}:8778/placement",
    internal_url        => "${internalurl}:8778/placement",
  }
}
