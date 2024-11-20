# Configures ceph for swift use
class ntnuopenstack::swift::ceph {
  $users = lookup('profile::ceph::keys', Hash)
  $hostname = $trusted['hostname']

  require ::profile::ceph::client

  ceph_config {
    "client.radosgw.${hostname}/key": 
      value => $users["client.radosgw.${hostname}"]['secret'];
  }

  ::profile::ceph::key { "client.radosgw.${hostname}": }
}
