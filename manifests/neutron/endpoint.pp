# Configures the neutron endpoint in keystone
define ntnuopenstack::neutron::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class { '::neutron::keystone::auth':
    admin_url    => "${adminurl}:9696",
    auth_name    => $username,
    internal_url => "${internalurl}:9696",
    password     => $password,
    public_url   => "${publicurl}:9696",
    region       => $region,
  }
}
