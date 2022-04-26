# Installs and configures the nova APIs.
class ntnuopenstack::nova::api {
  contain ::ntnuopenstack::nova::api::compute
  include ::ntnuopenstack::nova::api::logging
  contain ::ntnuopenstack::nova::api::metadata
  include ::ntnuopenstack::nova::api::sudo
}
