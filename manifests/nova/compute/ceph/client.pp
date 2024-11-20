# This class installs the ceph client and configures the nova-key. 
class ntnuopenstack::nova::compute::ceph::client {
  $ceph_user = lookup('ntnuopenstack::nova::ceph::user', {
    'default_value' => 'nova',
    'value_type'    => String,
  })
  $users = lookup('profile::ceph::keys', Hash)

  require ::profile::ceph::client

  # Configure ceph to accept the ceph-key for nova
  ceph_config {
    "client.${ceph_user}/key": value => $users["client.${ceph_user}"]['secret'];
  }
  
  ::profile::ceph::key { "client.${ceph_user}":
    group => 'nova',
    mode  => '0640',
  }
}
