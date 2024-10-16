# Configures the glance quota-system if it is needed. 
class ntnuopenstack::glance::quota {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $keystone_internal = lookup('ntnuopenstack::keystone::endpoint::internal',
      Stdlib::Httpurl)
  $region = lookup('ntnuopenstack::region', String)
  $use_keystone_limits = lookup('ntnuopenstack::glance::keystone::limits', {
    'default_value' => false,
    'value_type'    => Boolean,
  })

  # Configure the oslo_limit class if we should use the keystone limits.
  if($use_keystone_limits) {
    $endpoint_id = lookup('ntnuopenstack::glance::endpoint::internal::id', {
      'value_type' => String,
    })

    class { '::glance::limit':
      auth_url    => "${keystone_internal}:5000",
      endpoint_id => $endpoint_id,
      password    =>
        $services[$region]['services']['glance']['keystone']['password'],
      region_name => $region,
    }
  }
}
