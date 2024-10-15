# Configures the placement API endpoint in keystone 
define ntnuopenstack::placement::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class { '::placement::keystone::auth':
    admin_url    => "${adminurl}:8778/placement",
    auth_name    => $username,
    internal_url => "${internalurl}:8778/placement",
    password     => $password,
    public_url   => "${publicurl}:8778/placement",
    region       => $region,
  }
}
