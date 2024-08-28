# Defines the databases used by openstack
class ntnuopenstack::databases {
  include ::ntnuopenstack::cinder::database
  include ::ntnuopenstack::glance::database
  include ::ntnuopenstack::heat::database
  include ::ntnuopenstack::keystone::database
  include ::ntnuopenstack::neutron::database
  include ::ntnuopenstack::nova::database
  include ::ntnuopenstack::placement::database

  $barbican = lookup('ntnuopenstack::barbican::mysql::password', {
    'value_type'    => Variant[Boolean, String],
    'default_value' => false,
  })

  $magnum = lookup('ntnuopenstack::magnum::mysql::password', {
    'value_type'    => Variant[Boolean, String],
    'default_value' => false,
  })

  $octavia = lookup('ntnuopenstack::octavia::mysql::password', {
    'value_type'    => Variant[Boolean, String],
    'default_value' => false,
  })

  $zabbixservers = lookup('profile::zabbix::servers', {
    'default_value' => [],
    'value_type'    => Array[Stdlib::IP::Address::Nosubnet],
  })

  if($barbican) {
    include ::ntnuopenstack::barbican::database
  }

  if($magnum) {
    include ::ntnuopenstack::magnum::database
  }

  if($octavia) {
    include ::ntnuopenstack::octavia::database
  }

  if($zabbixservers =~ Array[Stdlib::IP::Address::Nosubnet, 1]) {
    include ::ntnuopenstack::zabbix::database
  }
}
