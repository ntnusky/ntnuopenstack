# Configure the endpoint and keystone user for barbican
define ntnuopenstack::barbican::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class { 'barbican::keystone::auth':
    admin_url    => "${adminurl}:9311",
    auth_name    => $username,
    internal_url => "${internalurl}:9311",
    password     => $password,
    public_url   => "${publicurl}:9311",
    region       => $region,
  }
}

