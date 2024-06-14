# Configures sudo for neutron
class ntnuopenstack::neutron::sudo {
  # if purge::unmanaged is true we purge all files in sudoers.d that is not 
  # managed by puppet. In this case we need to distribute «a» version of the
  # sudo-config for openstack-services to work. It is though better to use the
  # packaged version, so if the purge::unmanaged flag is set to false we will
  # not delete the packed version.
  $purge = lookup('profile::baseconfig::sudo::purge::unmanaged', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  if($purge) {
    sudo::conf { 'neutron_sudoers':
      ensure         => 'present',
      source         => 'puppet:///modules/ntnuopenstack/sudo/neutron_sudoers',
      sudo_file_name => 'neutron_sudoers',
    }
  }
}
