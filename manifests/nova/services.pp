# Installs various nova services.
class ntnuopenstack::nova::services {
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base
  contain ::ntnuopenstack::nova::neutron
  contain ::ntnuopenstack::nova::vncproxy

  class { [
    '::nova::scheduler',
    '::nova::cert',
    '::nova::consoleauth',
    '::nova::conductor'
  ]:
    enabled => true,
  }
}
