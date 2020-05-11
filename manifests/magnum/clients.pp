# Configure openstack clients for magnum
class ntnuopenstack::magnum::clients {
  $region = lookup('ntnuopenstack::region', String)

  class { '::magnum::clients::barbican':
    region_name => $region,
  }
  class { '::magnum::clients::cinder':
    region_name => $region,
  }
  class { '::magnum::clients::glance':
    region_name => $region,
  }
  class { '::magnum::clients::heat':
    region_name => $region,
  }
  class { '::magnum::clients::magnum':
    region_name => $region,
  }
  class { '::magnum::clients::neutron':
    region_name => $region,
  }
  class { '::magnum::clients::nova':
    region_name => $region,
  }

  # There is no class for octavia client in puppet-magnum.
  # Adding manally

  magnum_config {
    'octavia_client/region_name': value => $region;
  }
}
