# Defines the databases used by openstack
class ntnuopenstack::databases {
  include ::ntnuopenstack::cinder::database
  include ::ntnuopenstack::glance::database
  include ::ntnuopenstack::heat::database
  include ::ntnuopenstack::keystone::database
  include ::ntnuopenstack::neutron::database
  include ::ntnuopenstack::nova::database
}
