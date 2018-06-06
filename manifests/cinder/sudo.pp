# Configures sudo for cinder
class ntnuopenstack::cinder::sudo {
  sudo::conf { 'cinder_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/ntnuopenstack/sudo/cinder_sudoers',
    sudo_file_name => 'cinder_sudoers',
  }
}
