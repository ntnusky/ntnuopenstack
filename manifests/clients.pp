# This class installs the openstack clients.
class ntnuopenstack::clients {
  require ::ntnuopenstack::repo

  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  include ::cinder::client
  include ::nova::client
  include ::neutron::client
  include ::glance::client
  include ::heat::client

  ensure_packages('python3-openstackclient', {
    'ensure' => 'present',
  })

  # TODO: Remove when magnum is completly uninstalled
  ensure_packages('python3-magnumclient', {
    'ensure' => 'absent',
  })

  $services.each | $region, $data | {
    if('barbican' in $data['services']) {
      include ::barbican::client
    }
    if('octavia' in $data['services']) {
      include ::octavia::client
    }
  }
}
