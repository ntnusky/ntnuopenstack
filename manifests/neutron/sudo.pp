# Configures sudo for neutron
class ntnuopenstack::neutron::sudo {
  sudo::conf { 'neutron_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/ntnuopenstack/sudo/neutron_sudoers',
    sudo_file_name => 'neutron_sudoers',
  }
}
