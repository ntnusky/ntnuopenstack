# This class configures sudo for glance
class ntnuopenstack::glance::sudo {
  sudo::conf { 'glance_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/ntnuopenstack/sudo/glance_sudoers',
    sudo_file_name => 'glance_sudoers',
  }
}
