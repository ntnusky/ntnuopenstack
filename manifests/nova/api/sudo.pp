# Configures sudo to allow administration of the novaapi.
class ntnuopenstack::nova::api::sudo {
  sudo::conf { 'novaapi_sudoers':
    ensure         => 'present',
    source         => 'puppet:///modules/ntnuopenstack/sudo/novaapi_sudoers',
    sudo_file_name => 'novaapi_sudoers',
  }
}
