# Configures ceph for swift use
class ntnuopenstack::swift::ceph {
  $cephx_key = lookup('ntnuopenstack::swift::ceph::key', String)

  $hostname = $trusted['hostname']

  require ::profile::ceph::client

  ceph_config {
      "client.radosgw.${hostname}/key": value => $cephx_key;
  }

  ceph::key { "client.radosgw.${hostname}":
    secret  => $cephx_key,
    cap_mon => 'allow rwx',
    cap_osd => 'allow rwx',
    inject  => true,
  }
}
