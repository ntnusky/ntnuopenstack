# Configures the keystone endpoint
class ntnuopenstack::keystone::endpoint {
  $region            = lookup('ntnuopenstack::region', String)
  $admin_endpoint    = lookup('ntnuopenstack::keystone::endpoint::admin',
                                Stdlib::Httpurl)
  $internal_endpoint = lookup('ntnuopenstack::keystone::endpoint::internal',
                                Stdlib::Httpurl)
  $public_endpoint   = lookup('ntnuopenstack::keystone::endpoint::public',
                                Stdlib::Httpurl)

  $swift = lookup('ntnuopenstack::swift::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })

  $octavia = lookup('ntnuopenstack::octavia::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
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

  # If there is a password for octavia in hiera, define an endpoint for octavia.
  if($octavia) {
    include ::ntnuopenstack::octavia::endpoint
  }

  # Defining the keystone endpoint
  class { '::keystone::endpoint':
    public_url   => "${public_endpoint}:5000",
    admin_url    => "${admin_endpoint}:5000",
    internal_url => "${internal_endpoint}:5000",
    region       => $region,
    require      => Class['::keystone'],
  }
}
