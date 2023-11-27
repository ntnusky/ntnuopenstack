# Performs basic nova configuration for various services (api, schedulers etc).
class ntnuopenstack::nova::services::base {
  include ::ntnuopenstack::nova::common::base
  include ::ntnuopenstack::nova::common::cache
  require ::ntnuopenstack::nova::dbconnection
  require ::ntnuopenstack::repo
}
