# Configures the endpoint and keystone user for swift
class ntnuopenstack::swift::endpoint {
  $endpoint_admin = lookup('ntnuopenstack::endpoint::admin')
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $endpoint_public = lookup('ntnuopenstack::endpoint::public')

  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')
  $region = hiera('ntnuopenstack::region')

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
    $public = "${endpoint_public}:7480/swift/v1/%(project_id)s"
    $admin = "${endpoint_admin}:7480/swift/v1"
    $internal = "${endpoint_internal}:7480/swift/v1/%(project_id)s"
  } else {
    if($certificate) {
      $proto='https'
    } else {
      $proto='http'
    }

    $public = "${proto}://${swiftname}/swift/v1/%(project_id)s"
    $admin = "${proto}://${swiftname}/swift/v1"
    $internal = "${proto}://${swiftname}/swift/v1/%(project_id)s"
  }

  keystone::resource::service_identity { 'swift':
    configure_user      => true,
    configure_user_role => true,
    configure_endpoint  => true,
    service_type        => 'object-store',
    service_description => 'Openstack Object-Store Service',
    service_name        => 'swift',
    auth_name           => 'swift',
    region              => $region,
    password            => $keystone_password,
    email               => 'swift@localhost',
    tenant              => 'services',
    public_url          => $public,
    admin_url           => $admin,
    internal_url        => $internal,
  }
}
