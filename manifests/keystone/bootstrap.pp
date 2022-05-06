# Bootstraps our keystone-installation with admin-user and endpoint. 
class ntnuopenstack::keystone::bootstrap {
  $email = lookup('ntnuopenstack::keystone::admin_email', String)
  $password  = lookup('ntnuopenstack::keystone::admin_password', String)

  $admin    = lookup('ntnuopenstack::keystone::endpoint::admin',
                                Stdlib::Httpurl)
  $internal = lookup('ntnuopenstack::keystone::endpoint::internal',
                                Stdlib::Httpurl)
  $public   = lookup('ntnuopenstack::keystone::endpoint::public',
                                Stdlib::Httpurl)
  $region   = lookup('ntnuopenstack::region', String)

  $bootstrap = lookup('ntnuopenstack::keystone::bootstrap', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  class { '::keystone::bootstrap':
    admin_url    => "${admin}:5000",
    bootstrap    => $bootstrap,
    email        => $email,
    internal_url => "${internal}:5000",
    password     => $password,
    public_url   => "${public}:5000",
    region       => $region,
  }
}
