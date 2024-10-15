# Configures the required endpoints in keystone
class ntnuopenstack::keystone::endpoint {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  include ::ntnuopenstack::keystone::bootstrap

  $services.each | $region, $data | {
    $common = {
      adminurl    => $data['url']['admin'],
      internalurl => $data['url']['internal'],
      publicurl   => $data['url']['public'],
      region      => $region,
    }

    if('barbican' in $data['services']) {
      ::ntnuopenstack::barbican::endpoint { $region:
        password => $data['services']['barbican']['keystone']['password'],
        username => $data['services']['barbican']['keystone']['username'],
        *        => $common
      }
    }

    if('cinder' in $data['services']) {
      ::ntnuopenstack::cinder::endpoint { $region:
        password => $data['services']['cinder']['keystone']['password'],
        username => $data['services']['cinder']['keystone']['username'],
        *        => $common
      }
    }

    if('glance' in $data['services']) {
      ::ntnuopenstack::glance::endpoint { $region:
        password => $data['services']['glance']['keystone']['password'],
        username => $data['services']['glance']['keystone']['username'],
        *        => $common
      }
    }

    if('heat' in $data['services']) {
      ::ntnuopenstack::heat::endpoint { $region:
        password => $data['services']['heat']['keystone']['password'],
        username => $data['services']['heat']['keystone']['username'],
        *        => $common
      }
    }

    if('magnum' in $data['services']) {
      ::ntnuopenstack::magnum::endpoint { $region:
        password => $data['services']['magnum']['keystone']['password'],
        username => $data['services']['magnum']['keystone']['username'],
        *        => $common
      }
    }

    if('neutron' in $data['services']) {
      ::ntnuopenstack::neutron::endpoint { $region:
        password => $data['services']['neutron']['keystone']['password'],
        username => $data['services']['neutron']['keystone']['username'],
        *        => $common
      }
    }

    if('nova' in $data['services']) {
      ::ntnuopenstack::nova::endpoint { $region:
        password => $data['services']['nova']['keystone']['password'],
        username => $data['services']['nova']['keystone']['username'],
        *        => $common
      }
    }

    if('octavia' in $data['services']) {
      ::ntnuopenstack::octavia::endpoint { $region:
        password => $data['services']['octavia']['keystone']['password'],
        username => $data['services']['octavia']['keystone']['username'],
        *        => $common
      }
    }

    if('placement' in $data['services']) {
      ::ntnuopenstack::placement::endpoint { $region:
        password => $data['services']['placement']['keystone']['password'],
        username => $data['services']['placement']['keystone']['username'],
        *        => $common
      }
    }

    if('swift' in $data['services']) {
      ::ntnuopenstack::swift::endpoint { $region:
        password => $data['services']['swift']['keystone']['password'],
        username => $data['services']['swift']['keystone']['username'],
        *        => $common
      }
    }
  }
}
