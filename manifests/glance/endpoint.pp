# Registers the glance endpoint in keystone
define ntnuopenstack::glance::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::glance::deps

  Keystone::Resource::Service_identity["glance-${region}"] -> Anchor['glance::service::end']

  keystone::resource::service_identity { "glance-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'image',
    service_description => 'Openstack Image Service',
    service_name        => 'glance',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'glance@localhost',
    tenant              => 'services',
    roles               => ['admin'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:9292",
    admin_url           => "${adminurl}:9292",
    internal_url        => "${internalurl}:9292",
  }
}
