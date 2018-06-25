# Registers the heat endpoints in keystone
class ntnuopenstack::heat::endpoint {
  # Retrieve service IP Addresses
  $heat_admin_ip = hiera('profile::api::heat::admin::ip', '127.0.0.1')
  $heat_public_ip = hiera('profile::api::heat::public::ip', '127.0.0.1')

  # Retrieve api urls, if they exist. 
  $admin_endpoint    = hiera('ntnuopenstack::endpoint::admin', undef)
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal', undef)
  $public_endpoint   = hiera('ntnuopenstack::endpoint::public', undef)

  # Determine which endpoint to use
  $heat_admin     = pick($admin_endpoint, "http://${heat_admin_ip}")
  $heat_internal  = pick($internal_endpoint, "http://${heat_admin_ip}")
  $heat_public    = pick($public_endpoint, "http://${heat_public_ip}")

  # Other settings
  $heat_password = hiera('ntnuopenstack::heat::keystone::password')
  $region = hiera('ntnuopenstack::region')

  require ::ntnuopenstack::repo

  class  { '::heat::keystone::auth':
    password     => $heat_password,
    public_url   => "${heat_public}:8004/v1/%(tenant_id)s",
    internal_url => "${heat_internal}:8004/v1/%(tenant_id)s",
    admin_url    => "${heat_admin}:8004/v1/%(tenant_id)s",
    region       => $region,
  }

  class { '::heat::keystone::auth_cfn':
    password     => $heat_password,
    service_name => 'heat-cfn',
    region       => $region,
    public_url   => "${heat_public}:8000/v1",
    internal_url => "${heat_internal}:8000/v1",
    admin_url    => "${heat_admin}:8000/v1",
  }
}
