# Configures the compute-nodes providers 
class ntnuopenstack::nova::compute::provider {
  $providers = lookup('ntnuopenstack::nova::compute::providers', {
    'default_value' => {},
    'value_type'    => Hash[String,Hash], 
  })

  class {'::nova::compute::provider': 
    custom_inventories => $providers,
  }
}
