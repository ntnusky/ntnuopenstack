# Installs a radosgw for swift
class ntnuopenstack::swift::radosgw {
  ::ceph::rgw { 'radosgw.main':
  }
}
