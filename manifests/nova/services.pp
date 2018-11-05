# Installs various nova services.
class ntnuopenstack::nova::services {
  require ::ntnuopenstack::repo
  require ::ntnuopenstack::nova::base
  contain ::ntnuopenstack::nova::neutron
  contain ::ntnuopenstack::nova::vncproxy

  $discover_interval = lookup('ntnuopenstack::nova::discover_hosts_interval', 3600)

  class { [
    '::nova::consoleauth',
    '::nova::conductor'
  ]:
    enabled => true,
  }

  class { '::nova::scheduler':
    discover_hosts_in_cells_interval => $discover_interval,
  }
}
