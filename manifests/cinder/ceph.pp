# Configures ceph to facilitate for cinder, and for cinder to use ceph for
# storage.
class ntnuopenstack::cinder::ceph {
  $ceph_cinder_user = lookup('ntnuopenstack::cinder::ceph::user', String)
  $ceph_nova_user = lookup('ntnuopenstack::nova::ceph::user', {
    'default_value' => 'nova',
    'value_type'    => String,
  })
  $users = lookup('profile::ceph::keys', Hash)

  include ::cinder::deps
  require ::profile::ceph::client

  ceph_config {
    "client.${ceph_cinder_user}/key": value => $users["client.${ceph_cinder_user}"]['secret'];
    "client.${ceph_nova_user}/key": value => $users["client.${ceph_nova_user}"]['secret'];
  }

  ::profile::ceph::key { [
    "client.${ceph_cinder_user}",
    "client.${ceph_nova_user}",
  ] : 
    group  => 'cinder',
    mode   => '0640',
    before => Anchor['cinder::config::end'],
  }
}
