# Installs and configures the designate DNS integration for neutron
class ntnuopenstack::neutron::designate {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $auth_url = lookup('ntnuopenstack::keystone::auth::url')
  $region = lookup('ntnuopenstack::region', String)

  $api_url = $services[$region]['url']['internal'] 
  $designate_port = lookup('ntnuopenstack::designate::api::port')

  class { '::neutron::designate':
    url                       => "${api_url}:${designate_port}/v2",
    auth_url                  => $auth_url,
    password                  => 
      $services[$region]['services']['neutron']['keystone']['password'],
    username                  => 
      $services[$region]['services']['neutron']['keystone']['username'],
    project_name              => 'services',

    allow_reverse_dns_lookup  => true,
    ptr_zone_email            => lookup('ntnuopenstack::designate::hostmaster_email', Stdlib::Email),
    ipv6_ptr_zone_prefix_size => 64,
    ipv4_ptr_zone_prefix_size => 24,
  }
}

