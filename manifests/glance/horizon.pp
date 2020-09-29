# Configures glance to accept uploads directly from clients using horizon.
class ntnuopenstack::glance::horizon {
  $horizon_fqdn = lookup('ntnuopenstack::horizon::server_name')
  $horizon_url = "https://${horizon_fqdn}"
  $upload_mode = lookup('ntnuopenstack::horizon::upload_mode', {
    'value_type'   => Enum['legacy', 'direct', 'off'],
    'default_value' => 'legacy',
  })

  if ($upload_mode == 'direct') {
    glance_api_config {
      'cors/allowed_origin': value => $horizon_url;
      'cors/max_age':        value => 3600;
      'cors/allow_methods':  value => 'GET,PUT,POST,DELETE';
    }
  }
}
