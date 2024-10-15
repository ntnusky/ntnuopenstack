# Configures the keystone endpoint for the cinder API
define ntnuopenstack::cinder::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  class  { '::cinder::keystone::auth':
    admin_url_v3    => "${adminurl}:8776/v3/%(tenant_id)s",
    auth_name       => $username,
    internal_url_v3 => "${internalurl}:8776/v3/%(tenant_id)s",
    password        => $password,
    public_url_v3   => "${publicurl}:8776/v3/%(tenant_id)s",
    region          => $region,
    roles           => ['admin', 'service'],
  }
}
