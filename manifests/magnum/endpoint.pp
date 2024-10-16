# Configure the endpoint and keystone user for magnum
define ntnuopenstack::magnum::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  include ::ntnuopenstack::magnum::domain

  class { 'magnum::keystone::auth':
    admin_url    => "${adminurl}:9511/v1",
    auth_name    => $username,
    internal_url => "${internalurl}:9511/v1",
    password     => $password,
    public_url   => "${publicurl}:9511/v1",
    region       => $region,
  }
}

