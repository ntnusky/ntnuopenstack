# Installs and configures the barbican worker
class ntnuopenstack::barbican::worker {
  class { '::barbican::worker': }
}
