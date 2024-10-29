# Registers the heat endpoints in keystone
define ntnuopenstack::heat::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::heat::deps

  Keystone::Resource::Service_identity["heat-${region}"]
  -> Anchor['heat::service::end']
  Keystone::Resource::Service_identity["heat-cfn-${region}"]
  -> Anchor['heat::service::end']

  keystone::resource::service_identity { "heat-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'orchestration',
    service_description => 'Openstack Orchestration Service',
    service_name        => 'heat',
    region              => $region,
    auth_name           => $username,
    password            => $password,
    email               => 'heat@localhost',
    tenant              => 'services',
    roles               => ['admin'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:8004/v1/%(tenant_id)s",
    admin_url           => "${adminurl}:8004/v1/%(tenant_id)s",
    internal_url        => "${internalurl}:8004/v1/%(tenant_id)s",
  }

  keystone::resource::service_identity { "heat-cfn-${region}":
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    configure_service   => true,
    service_type        => 'cloudformation',
    service_description => 'Openstack Cloudformation Service',
    service_name        => 'heat-cfn',
    region              => $region,
    auth_name           => "${username}-cfn",
    password            => $password,
    email               => 'heat-cfn@localhost',
    tenant              => 'services',
    roles               => ['admin'],
    system_scope        => 'all',
    system_roles        => [],
    public_url          => "${publicurl}:8000/v1",
    admin_url           => "${adminurl}:8000/v1",
    internal_url        => "${internalurl}:8000/v1",
  }

  keystone_role { [
    'heat_stack_owner',
    'heat_stack_user',
  ] :
    ensure => present,
  }

  class { '::ntnuopenstack::heat::domain':
    create_domain => true,
  }
}
