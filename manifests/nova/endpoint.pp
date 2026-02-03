# Registers the nova api endpoint in keystone
define ntnuopenstack::nova::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::nova::deps

  Keystone::Resource::Service_identity["nova-${region}"] -> Anchor['nova::service::end']

  keystone::resource::service_identity { "nova-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'compute',
    service_description => 'OpenStack Compute Service',
    service_name        => 'nova',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'nova@localhost',
    tenant              => 'services',
    roles               => ['admin', 'service'],
    system_scope        => 'all',
    system_roles        => ['reader'],
    public_url          => "${publicurl}:8774/v2.1",
    admin_url           => "${adminurl}:8774/v2.1",
    internal_url        => "${internalurl}:8774/v2.1",
  }
}
