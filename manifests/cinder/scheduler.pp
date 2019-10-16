# Installs the cinder scheduler
class ntnuopenstack::cinder::scheduler {
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::cinder::base

  class { '::cinder::scheduler': }
}
