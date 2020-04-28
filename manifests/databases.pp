# Defines the databases used by openstack
class ntnuopenstack::databases {
  include ::ntnuopenstack::cinder::database
  include ::ntnuopenstack::glance::database
  include ::ntnuopenstack::heat::database
  include ::ntnuopenstack::keystone::database
  include ::ntnuopenstack::neutron::database
  include ::ntnuopenstack::nova::database

  $barbican = lookup('ntnuopenstack::barbican::mysql::password', {
    'value_type'    => Variant[Boolean, String],
    'default_value' => false,
  })

  $octavia = lookup('ntnuopenstack::octavia::mysql::password', {
    'value_type'    => Variant[Boolean, String],
    'default_value' => false,
  })

  $magnum = lookup('ntnuopenstack::magnum::mysql::password', {
    'value_type'    => Variant[Boolean, String],
    'default_value' => false,
  })
  if($barbican) {
    include ::ntnuopenstack::barbican::database
  }

  if($octavia) {
    include ::ntnuopenstack::octavia::database
  }

  if($magnum) {
    include ::ntnuopenstack::magnum::database
  }
}
