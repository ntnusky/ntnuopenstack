# This class installs the openstack clients.
class ntnuopenstack::clients {
  require ::ntnuopenstack::repo

  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  include ::keystone::client
  include ::cinder::client
  include ::nova::client
  include ::neutron::client
  include ::glance::client
  include ::heat::client

  $services.each | $region, $data | {
    if('barbican' in $data['services']) {
      include ::barbican::client
    }
    if('octavia' in $data['services']) {
      include ::octavia::client
    }
    if('magnum' in $data['services']) {
      include ::magnum::client
    }
  }
}
