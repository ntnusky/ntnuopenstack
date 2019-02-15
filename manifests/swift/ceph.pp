# Configures ceph for swift use
class ntnuopenstack::swift::ceph {
  $cephx_key = lookup('ntnuopenstack::swift::ceph::key', String)

  require ::profile::ceph::client

  ceph_config {
      'client.radosgw.main/key': value => $cephx_key;
  }

  ceph::key { 'client.radosgw.main':
    secret  => $cephx_key,
    cap_mon => 'allow rwx',
    cap_osd => 'allow rwx',
    inject  => true,
  }
}
