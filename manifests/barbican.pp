# Installs and configures the barbican api and worker
class ntnuopenstack::barbican {
  include ::ntnuopenstack::barbican::api
  include ::ntnuopenstack::barbican::crypto
  include ::barbican::worker
  require ::ntnuopenstack::repo
}
