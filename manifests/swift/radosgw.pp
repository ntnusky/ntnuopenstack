# Installs a radosgw for swift
class ntnuopenstack::swift::radosgw {
  $endpoint_internal = lookup('ntnuopenstack::endpoint::internal')
  $keystone_password = lookup('ntnuopenstack::swift::keystone::password')

  # The default quota is set to 20GB here per project, but this can be
  # overridden through hiera. Quotas per project can also be set on the
  # radosgws. 
  $default_limit = lookup('ntnuopenstack::swift::quota::size', {
    'value_type'    => Integer,
    'default_value' => 21474836480,
  })

  ::ceph::rgw { 'radosgw.main':
    pkg_radosgw => 'radosgw',
    user        => 'www-data',
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
    'global/rgw user default quota max size':       value => $default_limit;
  }
}
