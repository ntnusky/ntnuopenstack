# Installs and configures the nova APIs.
class ntnuopenstack::nova::api {
  contain ::ntnuopenstack::nova::api::compute
  contain ::ntnuopenstack::nova::api::metadata
  include ::ntnuopenstack::nova::api::sudo
  require ::ntnuopenstack::nova::dbconnection
}
