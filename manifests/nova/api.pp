# Installs and configures the nova APIs.
class ntnuopenstack::nova::api {
  contain ::ntnuopenstack::nova::api::compute
  contain ::ntnuopenstack::nova::api::placement
}
