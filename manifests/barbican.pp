# Installs and configures the barbican api and worker
class ntnuopenstack::barbican {
  include ::barbican::worker
  include ::ntnuopenstack::barbican::api
  include ::ntnuopenstack::barbican::crypto
  include ::ntnuopenstack::barbican::logging
  require ::ntnuopenstack::repo
}
