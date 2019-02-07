# Registers the heat endpoints in keystone
class ntnuopenstack::heat::endpoint {
  $region = lookup('ntnuopenstack::region', String)
  $password = lookup('ntnuopenstack::heat::keystone::password', String)

  $heat_admin    = lookup('ntnuopenstack::heat::endpoint::admin',
                              Stdlib::Httpurl)
  $heat_internal = lookup('ntnuopenstack::heat::endpoint::internal',
                              Stdlib::Httpurl)
  $heat_public   = lookup('ntnuopenstack::heat::endpoint::public',
                              Stdlib::Httpurl)

  require ::ntnuopenstack::repo

  class  { '::heat::keystone::auth':
    password     => $password,
    public_url   => "${heat_public}:8004/v1/%(tenant_id)s",
    internal_url => "${heat_internal}:8004/v1/%(tenant_id)s",
    admin_url    => "${heat_admin}:8004/v1/%(tenant_id)s",
    region       => $region,
  }

  class { '::heat::keystone::auth_cfn':
    password     => $password,
    service_name => 'heat-cfn',
    region       => $region,
    public_url   => "${heat_public}:8000/v1",
    internal_url => "${heat_internal}:8000/v1",
    admin_url    => "${heat_admin}:8000/v1",
  }
}
