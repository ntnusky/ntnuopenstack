# Installs and configures a swift server. 
class ntnuopenstack::swift {
  include ::ntnuopenstack::swift::ceph
  include ::ntnuopenstack::swift::firewall::server
  include ::ntnuopenstack::swift::haproxy::backend
  include ::ntnuopenstack::swift::radosgw

  Class['ntnuopenstack::swift::ceph'] -> Class['ntnuopenstack::swift::radosgw']
}
