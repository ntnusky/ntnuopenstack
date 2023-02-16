# Installs and configures magnum api and magnum conductor
class ntnuopenstack::magnum {
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::common
  include ::ntnuopenstack::magnum::api
  include ::magnum::conductor
  include ::profile::services::apache::logging
}
