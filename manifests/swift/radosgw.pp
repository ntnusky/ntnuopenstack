# Installs a radosgw for swift
class ntnuopenstack::swift::radosgw {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $region = lookup('ntnuopenstack::region', String)

  $keystone_roles = lookup('ntnuopenstack::swift::keystone::roles', {
    'default_value' => [ 'member', 'admin' ],
    'value_type'    => Array[String],
  })

  if('dnsname' in $services[$region]['services']['swift']) {
    $swiftname = $services[$region]['services']['swift']['dnsname']
  } else {
    $swiftname = $::fqdn
  }

  $hostname = $trusted['hostname']

  ::ceph::rgw { "radosgw.${hostname}":
    frontend_type            => 'beast',
    pkg_radosgw              => 'radosgw',
    rgw_dns_name             => $swiftname,
    rgw_swift_account_in_url => true,
    user                     => 'ceph',
  }

  ::ceph::rgw::keystone { "radosgw.${hostname}":
    rgw_keystone_url            => $auth_url,
    rgw_keystone_accepted_roles => join($keystone_roles, ' '),
    rgw_keystone_admin_domain   => 'Default',
    rgw_keystone_admin_project  => 'services',
    rgw_keystone_admin_user     =>
      $services[$region]['services']['swift']['keystone']['username'],
    rgw_keystone_admin_password =>
      $services[$region]['services']['swift']['keystone']['password'],
  }

  ceph_config {
    "client.radosgw.${hostname}/rgw_enable_usage_log": value => true; 
  }
}
