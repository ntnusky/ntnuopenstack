# Performs basic nova configuration for various services (api, schedulers etc).
class ntnuopenstack::nova::services::base {
  # Determine if quotas should be counted through placement
  $placement_quota = lookup('ntnuopenstack::nova::quota::placement', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  include ::ntnuopenstack::nova::common::base
  include ::ntnuopenstack::nova::common::cache
  require ::ntnuopenstack::nova::dbconnection
  require ::ntnuopenstack::repo

  nova_config {
    'quota/count_usage_from_placement': value => $placement_quota;
  }
}
