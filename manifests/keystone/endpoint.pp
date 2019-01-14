# Configures the keystone endpoint
class ntnuopenstack::keystone::endpoint {
  $region = hiera('ntnuopenstack::region')
  $admin_ip = hiera('profile::api::keystone::admin::ip', '127.0.0.1')
  $public_ip = hiera('profile::api::keystone::public::ip', '127.0.0.1')

  $admin_endpoint = hiera('ntnuopenstack::endpoint::admin',
      "http://${admin_ip}")
  $internal_endpoint = hiera('ntnuopenstack::endpoint::internal',
      "http://${admin_ip}")
  $public_endpoint = hiera('ntnuopenstack::endpoint::public',
      "http://${public_ip}")

  $swift = lookup('ntnuopenstack::swift::keystone::password', {
    'default_value': false,
  })

  # We need to define the endpoints on the keystone hosts, so include the other
  # endpoints here.
  include ::ntnuopenstack::cinder::endpoint
  include ::ntnuopenstack::glance::endpoint
  include ::ntnuopenstack::heat::endpoint
  include ::ntnuopenstack::neutron::endpoint
  include ::ntnuopenstack::nova::endpoint::api
  include ::ntnuopenstack::nova::endpoint::placement

  # If there is a password for swift in hiera, define an endpoint for swift.
  if($swift) {
    include ::ntnuopenstack::swift::endpoint
  }

  # Defining the keystone endpoint
  class { '::keystone::endpoint':
    public_url   => "${public_endpoint}:5000",
    admin_url    => "${admin_endpoint}:35357",
    internal_url => "${internal_endpoint}:5000",
    region       => $region,
    require      => Class['::keystone'],
  }
}
