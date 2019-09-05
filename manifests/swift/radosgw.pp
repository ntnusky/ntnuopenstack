# Installs a radosgw for swift
class ntnuopenstack::swift::radosgw {
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')
  $swift_dns_name = lookup('ntnuopenstack::swift::dns::name')

  ::ceph::rgw { 'radosgw.main':
    pkg_radosgw  => 'radosgw',
    rgw_dns_name => $swift_dns_name,
    user         => 'www-data',
  }

  ::ceph::rgw::keystone { 'radosgw.main':
    rgw_keystone_url            => "${endpoint_internal}:5000",
    rgw_keystone_version        => 'v3',
    rgw_keystone_accepted_roles => '_member_ admin',
    rgw_keystone_admin_domain   => 'Default',
    rgw_keystone_admin_project  => 'services',
    rgw_keystone_admin_user     => 'swift',
    rgw_keystone_admin_password => $keystone_password,
    use_pki                     => false,
  }

  ceph_config {
    'client.radosgw.main/rgw swift account in url': value => true;
  }
}
