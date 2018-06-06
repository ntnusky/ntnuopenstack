# This class installs the openstack clients.
class ntnuopenstack::clients {
  require ::ntnuopenstack::repo

  include ::keystone::client
  include ::cinder::client
  include ::nova::client
  include ::neutron::client
  include ::glance::client
  include ::heat::client
}
