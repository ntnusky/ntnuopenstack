# Installs a radosgw for swift
class ntnuopenstack::swift::radosgw {
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')
  $swift_dns_name = lookup('ntnuopenstack::swift::dns::name')
  $keystone_roles = lookup('ntnuopenstack::swift::keystone::roles', {
    'default_value' => [ '_member_', 'admin' ],
    'value_type'    => Array[String],
  })

  $hostname = $trusted['hostname']

  ::ceph::rgw { "radosgw.${hostname}":
    frontend_type => 'beast',
    pkg_radosgw   => 'radosgw',
    rgw_dns_name  => $swift_dns_name,
    user          => 'ceph',
  }

  ::ceph::rgw::keystone { "radosgw.${hostname}":
    rgw_keystone_url            => "${endpoint_internal}:5000",
    rgw_keystone_accepted_roles => join($keystone_roles, ' '),
    rgw_keystone_admin_domain   => 'Default',
    rgw_keystone_admin_project  => 'services',
    rgw_keystone_admin_user     => 'swift',
    rgw_keystone_admin_password => $keystone_password,
  }

  ceph_config {
    "client.radosgw.${hostname}/rgw swift account in url": value => true;
  }
}
