# Installs a radosgw for swift
class ntnuopenstack::swift::radosgw {
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')

  ::ceph::rgw { 'radosgw.main':
  }

  ::ceph::rgw::keystone { 'radosgw.main':
    rgw_keystone_url            => "${endpoint_internal}:5000"
    rgw_keystone_version        => 'v3',
    rgw_keystone_accepted_roles => 'admin',
    rgw_keystone_admin_domain   => 'Default',
    rgw_keystone_admin_project  => 'services',
    rgw_keystone_admin_user     => 'swift',
    rgw_keystone_admin_password => $keystone_password,
    use_pki                     => false,
  }
}
