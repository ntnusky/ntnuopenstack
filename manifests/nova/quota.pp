# Installs and configures the nova compute API.
class ntnuopenstack::nova::quota {
  # Retrieve parameters from hiera
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')
  $region = lookup('ntnuopenstack::region')
  $use_keystone_limits = lookup('ntnuopenstack::nova::keystone::limits', {
    'default_value' => false,
    'value_type'    => Boolean,
  })
  # Determine if quotas should be counted through placement
  $placement_quota = lookup('ntnuopenstack::nova::quota::placement', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  # Configure the oslo_limit class if we should use the keystone limits.
  if($use_keystone_limits) {
    $endpoint_id = lookup('ntnuopenstack::nova::endpoint::internal::id', {
      'value_type' => String,
    })

    class { '::nova::limit':
      auth_url    => "${internal_endpoint}:5000",
      endpoint_id => $endpoint_id,
      password    =>
        $services[$region]['services']['nova']['keystone']['password'],
      region_name => $region,
    }
    $driver_opts = {
      'driver' => 'nova.quota.UnifiedLimitsDriver',
    }
  } else {
    $driver_opts = {}
  }

  class { '::nova::quota':
    count_usage_from_placement => $placement_quota,
    *                          => $driver_opts,
  }

}
