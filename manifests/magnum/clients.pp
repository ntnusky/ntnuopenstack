# Configure openstack clients for magnum
class ntnuopenstack::magnum::clients {
  $region = lookup('ntnuopenstack::region', String)

  class { '::magnum::clients':
    region_name => $region,
  }
}
