# Installs and configures the glance API
class ntnuopenstack::glance {
  contain ::ntnuopenstack::glance::api
  include ::ntnuopenstack::glance::logging
}
