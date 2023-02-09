# Registers the glance endpoint in keystone
class ntnuopenstack::glance::endpoint {
  $region = lookup('ntnuopenstack::region', String)
  $password = lookup('ntnuopenstack::glance::keystone::password', String)

  $glance_admin    = lookup('ntnuopenstack::glance::endpoint::admin',
                              Stdlib::Httpurl)
  $glance_internal = lookup('ntnuopenstack::glance::endpoint::internal',
                              Stdlib::Httpurl)
  $glance_public   = lookup('ntnuopenstack::glance::endpoint::public',
                              Stdlib::Httpurl)

  class  { '::glance::keystone::auth':
    admin_url    => "${glance_admin}:9292",
    internal_url => "${glance_internal}:9292",
    password     => $password,
    public_url   => "${glance_public}:9292",
    region       => $region,
    system_roles => [ 'reader' ],
  }
}
