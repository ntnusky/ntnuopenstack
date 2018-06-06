# Configures sudo for the nova service.
class ntnuopenstack::nova::sudo {
  sudo::conf { 'nova_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/ntnuopenstack/sudo/nova_sudoers',
    sudo_file_name => 'nova_sudoers',
  }
}
