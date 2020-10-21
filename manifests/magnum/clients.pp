# Configure openstack clients for magnum
class ntnuopenstack::magnum::clients {
  $region = lookup('ntnuopenstack::region', String)

  class { '::magnum::clients':
    region_name => $region,
  }

  # There is no class for octavia client in puppet-magnum.
  # Adding manally

  magnum_config {
    'octavia_client/region_name': value => $region;
  }
}
