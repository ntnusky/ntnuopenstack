# Configures the endpoint and keystone user for swift
class ntnuopenstack::swift::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')
  $region = lookup('ntnuopenstack::region')

  $swiftname = lookup('ntnuopenstack::swift::dns::name', {
    'default_value' => false,
  })
  $certificate = lookup('profile::haproxy::services::webcert', {
    'default_value' => false,
  })

  # If no name is set for swift, the service is placed under the regular API
  # endpoint at port 7480. If name is set swift is placed at port 80/443 under
  # the supplied name.
  if($swiftname) {
    if($certificate) {
      $proto='https'
    } else {
      $proto='http'
    }

    $public = "${proto}://${swiftname}/swift/v1/%(project_id)s"
    $admin = "${proto}://${swiftname}/swift/v1/%(project_id)s"
    $internal = "${proto}://${swiftname}/swift/v1/%(project_id)s"
  } else {
    $public = "${endpoint_public}:7480/swift/v1/%(project_id)s"
    $admin = "${endpoint_admin}:7480/swift/v1/%(project_id)s"
    $internal = "${endpoint_internal}:7480/swift/v1/%(project_id)s"
  }

  keystone::resource::service_identity { 'swift':
    admin_url           => $admin,
    auth_name           => 'swift',
    email               => 'swift@localhost',
    configure_endpoint  => true,
    configure_user      => true,
    configure_user_role => true,
    internal_url        => $internal,
    password            => $keystone_password,
    public_url          => $public,
    region              => $region,
    service_description => 'Openstack Object-Store Service',
    service_name        => 'swift',
    service_type        => 'object-store',
    tenant              => 'services',
  }
}
