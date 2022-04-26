# sudo config for nova-compute
class ntnuopenstack::nova::compute::sudo {
  sudo::conf { 'nova-compute':
    priority => 50,
    source   => 'puppet:///modules/ntnuopenstack/sudo/novacompute_sudoers',
  }
}
