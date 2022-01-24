# Performs basic nova configuration for various services (api, schedulers etc).
class ntnuopenstack::nova::services::base {
  # Retrieve mysql parameters
  $mysql_password = lookup('ntnuopenstack::nova::mysql::password')
  $mysql_ip = lookup('ntnuopenstack::nova::mysql::ip', {
      'value_type' => Stdlib::IP::Address,
  })
  $api_db_con = "mysql+pymysql://nova_api:${mysql_password}@${mysql_ip}/nova_api"

  # Determine if quotas should be counted through placement
  $placement_quota = lookup('ntnuopenstack::nova::quota::placement', {
    'value_type'    => Boolean,
    'default_value' => true,
  })

  include ::ntnuopenstack::nova::common::cache
  include ::ntnuopenstack::nova::common::placement
  include ::ntnuopenstack::nova::common::sudo
  require ::ntnuopenstack::repo

  class { '::ntnuopenstack::nova::common::base':
    extra_options => {
      'api_database_connection' => $api_db_con,
    },
  }

  nova_config {
    'quota/count_usage_from_placement': value => $placement_quota;
  }
}
