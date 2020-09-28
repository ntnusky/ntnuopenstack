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

  class { '::keystone::bootstrap':
    email        => $email,
    password     => $password,
    admin_url    => "${admin}:5000",
    internal_url => "${internal}:5000",
    public_url   => "${public}:5000",
    region       => $region,
  }
}
