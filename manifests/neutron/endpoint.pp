# Configures the neutron endpoint in keystone
define ntnuopenstack::neutron::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::neutron::deps

  Keystone::Resource::Service_identity["neutron-${region}"] -> Anchor['neutron::service::end']

  keystone::resource::service_identity { "neutron-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'network',
    service_description => 'OpenStack Networking Service',
    service_name        => 'neutron',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'neutron@localhost',
    tenant              => 'services',
    roles               => ['admin'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:9696",
    admin_url           => "${adminurl}:9696",
    internal_url        => "${internalurl}:9696",
  }
}
