# Registers the glance endpoint in keystone
define ntnuopenstack::glance::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class  { '::glance::keystone::auth':
    admin_url    => "${adminurl}:9292",
    auth_name    => $username,
    internal_url => "${internalurl}:9292",
    password     => $password,
    public_url   => "${publicurl}:9292",
    region       => $region,
  }
}
