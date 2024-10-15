# Registers the nova api endpoint in keystone
define ntnuopenstack::nova::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class { '::nova::keystone::auth':
    admin_url    => "${adminurl}:8774/v2.1",
    internal_url => "${internalurl}:8774/v2.1",
    password     => $password,
    public_url   => "${publicurl}:8774/v2.1",
    region       => $region,
    roles        => ['admin', 'service'],
  }
}
