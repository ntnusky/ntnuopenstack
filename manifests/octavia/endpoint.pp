# Configures the endpoint and keystone user for swift
define ntnuopenstack::octavia::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class { 'octavia::keystone::auth':
    admin_url    => "${adminurl}:9876",
    auth_name    => $username,
    internal_url => "${internalurl}:9876",
    password     => $password,
    public_url   => "${publicurl}:9876",
    region       => $region,
  }
}
