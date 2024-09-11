# Installs and configures a swift server. 
class ntnuopenstack::swift {
  $installmunin = lookup('profile::munin::install', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  include ::ntnuopenstack::swift::ceph
  include ::ntnuopenstack::swift::firewall::server
  include ::ntnuopenstack::swift::haproxy::backend
  include ::ntnuopenstack::swift::radosgw
  include ::profile::ceph::zabbix::radosgw

  if($installmunin) {
    include ::ntnuopenstack::swift::munin::plugins
  }
}
