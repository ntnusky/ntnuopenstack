# Configures the endpoint and keystone user for swift
define ntnuopenstack::swift::endpoint (
  Stdlib::Httpurl $adminurl,
  Stdlib::Httpurl $internalurl,
  String          $password,
  Stdlib::Httpurl $publicurl,
  String          $region,
  String          $username,
) {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  if('dnsname' in $services[$region]['services']['swift']) {
    $swiftname = $services[$region]['services']['swift']['dnsname']
  } else {
    $swiftname = false
  }

  # If no name is set for swift, the service is placed under the regular API
  # endpoint at port 7480. If name is set swift is placed at port 80/443 under
  # the supplied name.
  if($swiftname) {
    $certificate = lookup('profile::haproxy::services::webcert', {
      'default_value' => false,
    })

    if($certificate) {
      $proto='https'
    } else {
      $proto='http'
    }

    $public = "${proto}://${swiftname}/swift/v1/%(project_id)s"
    $admin = "${proto}://${swiftname}/swift/v1/%(project_id)s"
    $internal = "${proto}://${swiftname}/swift/v1/%(project_id)s"
  } else {
    $public = "${publicurl}:7480/swift/v1/%(project_id)s"
    $admin = "${adminurl}:7480/swift/v1/%(project_id)s"
    $internal = "${internalurl}:7480/swift/v1/%(project_id)s"
  }

  keystone::resource::service_identity { "swift-${region}":
    admin_url           => $admin,
    auth_name           => $username,
    email               => 'swift@localhost',
    configure_endpoint  => true,
    configure_user      => true,
    configure_user_role => true,
    internal_url        => $internal,
    password            => $password,
    public_url          => $public,
    region              => $region,
    service_description => 'OpenStack Object-Store Service',
    service_name        => 'swift',
    service_type        => 'object-store',
    tenant              => 'services',
  }
}
