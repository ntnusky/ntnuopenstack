# Configures the endpoint and keystone user for swift
define ntnuopenstack::octavia::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::octavia::deps

  Keystone::Resource::Service_identity["octavia-${region}"]
  -> Anchor['octavia::service::end']

  keystone::resource::service_identity { "octavia-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'load-balancer',
    service_description => 'OpenStack Load Balancing Service',
    service_name        => 'octavia',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'octavia@localhost',
    tenant              => 'services',
    roles               => ['admin', 'service'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:9876",
    admin_url           => "${adminurl}:9876",
    internal_url        => "${internalurl}:9876",
  }
}
