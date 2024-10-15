# Registers the heat endpoints in keystone
define ntnuopenstack::heat::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class  { '::heat::keystone::auth':
    admin_url    => "${adminurl}:8004/v1/%(tenant_id)s",
    auth_name    => $username,
    internal_url => "${internalurl}:8004/v1/%(tenant_id)s",
    password     => $password,
    public_url   => "${publicurl}:8004/v1/%(tenant_id)s",
    region       => $region,
  }

  class { '::heat::keystone::auth_cfn':
    admin_url    => "${adminurl}:8000/v1",
    auth_name    => $username,
    internal_url => "${internalurl}:8000/v1",
    password     => $password,
    public_url   => "${publicurl}:8000/v1",
    service_name => 'heat-cfn',
    region       => $region,
  }

  class { '::ntnuopenstack::heat::domain':
    create_domain => true,
  }
}
