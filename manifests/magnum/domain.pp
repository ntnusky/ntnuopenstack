# Configure keystone domain for magnum. This class should be included by keystone
# This is basically copied from ::magnum::keystone::domain
# because we need a split. The keystone resources must be configured
# on the keystone hosts. Magnum config on the magnum hosts.
class ntnuopenstack::magnum::domain {
  $domain_admin = lookup('ntnuopenstack::magnum::domain_admin', {
    'value_type'    => String,
    'default_value' => 'magnum_admin',
  })
  $domain_admin_email = lookup('ntnuopenstack::magnum::domain_admin_email', {
    'value_type'    => String,
    'default_value' => 'magnum_admin@localhost',
  })
  $domain_name = lookup('ntnuopenstack::magnum::domain_name', {
    'value_type'    => String,
    'default_value' => 'magnum',
  })
  $domain_password = lookup('ntnuopenstack::magnum::domain_password', String)
  ensure_resource('keystone_domain', $domain_name, {
      'ensure'  => 'present',
      'enabled' => true,
    }
  )

  ensure_resource('keystone_user', "${domain_admin}::${domain_name}", {
      'ensure'   => 'present',
      'enabled'  => true,
      'email'    => $domain_admin_email,
      'password' => $domain_password,
    }
  )

  ensure_resource('keystone_user', "${domain_admin}::${domain_name}", {
      'ensure'   => 'present',
      'enabled'  => true,
      'email'    => $domain_admin_email,
      'password' => $domain_password,
    }
  )

  ensure_resource('keystone_user_role', "${domain_admin}::${domain_name}@::${domain_name}", {
      'roles' => ['admin'],
    }
  )
}
