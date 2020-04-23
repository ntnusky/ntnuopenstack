# This class installs the openstack clients.
class ntnuopenstack::clients {
  require ::ntnuopenstack::repo

  $barbican = lookup('ntnuopenstack::barbican::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })
  
  $octavia = lookup('ntnuopenstack::octavia::keystone::password', {
    'default_value' => false,
    'value_type'    => Variant[Boolean, String],
  })

  include ::keystone::client
  include ::cinder::client
  include ::nova::client
  include ::neutron::client
  include ::glance::client
  include ::heat::client

  if($barbican) {
    include ::barbican::client
  }

  if($octavia) {
    include ::octavia::client
  }
}
