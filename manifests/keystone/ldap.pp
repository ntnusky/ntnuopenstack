# Configures keystone to use an LDAP backend for authentication
class ntnuopenstack::keystone::ldap {
  $ldap_name = lookup('ntnuopenstack::keystone::ldap_backend::name', String)
  $url  = lookup('ntnuopenstack::keystone::ldap_backend::url',  String)
  $user = lookup('ntnuopenstack::keystone::ldap_backend::user', String)
  $password = lookup('ntnuopenstack::keystone::ldap_backend::password', String)
  $suffix = lookup('ntnuopenstack::keystone::ldap_backend::suffix', String)
  $user_tree_dn = lookup(
    'ntnuopenstack::keystone::ldap_backend::user_tree_dn', String
  )
  $user_filter = lookup(
    'ntnuopenstack::keystone::ldap_backend::user_filter', {
      'value_type'    => Variant[Undef, String],
      'default_value' => undef,
  })
  $user_objectclass = lookup(
    'ntnuopenstack::keystone::ldap_backend::user_objectclass', {
      'value_type'    => String,
      'default_value' => 'person',
  })
  $user_id_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::user_id_attribute', String
  )
  $user_name_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::user_name_attribute', String
  )
  $user_mail_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::user_mail_attribute', {
      'value_type'    => String,
      'default_value' => 'mail',
  })

  # Assume AD if we find sAMAccountName and set some AD specific defaults
  if ($user_id_attribute == 'sAMAccountName') {
    $user_enabled_attribute = 'userAccountControl'
    $user_enabled_mask = 2
    $user_enabled_default = 512
    $group_ad_nesting = true
    $group_members_are_ids = false
  } else {
    $user_enabled_attribute = undef
    $user_enabled_mask = undef
    $user_enabled_default = undef
    $group_ad_nesting = undef
    $group_members_are_ids = true
  }

  $group_tree_dn = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_tree_dn',
    String,
  )
  $group_filter = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_filter', {
      'value_type'    => Variant[Undef, String],
      'default_value' => undef,
  })
  $group_objectclass = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_objectclass', String
  )
  $group_id_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_id_attribute', String
  )
  $group_name_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_name_attribute', String
  )
  $group_member_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_member_attribute', String
  )
  $group_desc_attribute = lookup(
    'ntnuopenstack::keystone::ldap_backend::group_desc_attribute', {
      'value_type'    => Variant[Undef, String],
      'default_value' => undef,
  })

  require ::ntnuopenstack::repo

  keystone::ldap_backend { $ldap_name:
    create_domain_entry    => true,
    url                    => $url,
    user                   => $user,
    password               => $password,
    suffix                 => $suffix,
    query_scope            => sub,
    page_size              => 1000,
    user_tree_dn           => $user_tree_dn,
    user_filter            => $user_filter,
    user_objectclass       => $user_objectclass,
    user_id_attribute      => $user_id_attribute,
    user_name_attribute    => $user_name_attribute,
    user_mail_attribute    => $user_mail_attribute,
    user_enabled_attribute => $user_enabled_attribute,
    user_enabled_mask      => $user_enabled_mask,
    user_enabled_default   => $user_enabled_default,
    group_ad_nesting       => $group_ad_nesting,
    group_tree_dn          => $group_tree_dn,
    group_filter           => $group_filter,
    group_objectclass      => $group_objectclass,
    group_id_attribute     => $group_id_attribute,
    group_name_attribute   => $group_name_attribute,
    group_member_attribute => $group_member_attribute,
    group_members_are_ids  => $group_members_are_ids,
    group_desc_attribute   => $group_desc_attribute,
    use_tls                => false,
  }

  keystone_domain_config {
    "${ldap_name}::identity/list_limit": value   => '100';
  }

  Keystone::Ldap_backend[$ldap_name] ~> Exec<| title == 'restart_keystone' |>
}
