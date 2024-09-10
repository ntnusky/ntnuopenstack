# Installs and configures a swift server. 
class ntnuopenstack::swift {
  include ::ntnuopenstack::swift::ceph
  include ::ntnuopenstack::swift::firewall::server
  include ::ntnuopenstack::swift::haproxy::backend
  include ::ntnuopenstack::swift::munin::plugins
  include ::ntnuopenstack::swift::radosgw
  include ::profile::ceph::zabbix::radosgw
}
