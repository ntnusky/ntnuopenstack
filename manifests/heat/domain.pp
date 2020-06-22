# Configures a keystone domain for heat
class ntnuopenstack::heat::domain (
  $create_domain,
) {
  # Logic: when class is included by keystone, set $create_domain to true
  # When imported by heat, set $create_domain to false
  if($create_domain) {
    $manage_keystone = true
    $manage_config = false
  } else {
    $manage_keystone = false
    $manage_config = true
  }

  $domain_password = lookup('ntnuopenstack::heat::domain_password', String)

  class { '::heat::keystone::domain':
    manage_domain   => $manage_keystone,
    manage_user     => $manage_keystone,
    manage_role     => $manage_keystone,
    manage_config   => $manage_config,
    domain_password => $domain_password,
  }
}
