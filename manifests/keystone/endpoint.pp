# Configures the required endpoints in keystone
class ntnuopenstack::keystone::endpoint {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  include ::ntnuopenstack::keystone::bootstrap

  $services.each | $region, $regiondata | {
    $regiondata['services'].each | $service, $servicedata | {
      "::ntnuopenstack::${service}::endpoint" { "${region}-${service}":
        adminurl    => $regiondata['url']['admin'],
        internalurl => $regiondata['url']['internal'],
        password    => $servicedata['keystone']['password'],
        publicurl   => $regiondata['url']['public'],
        region      => $region,
        username    => $servicedata['keystone']['username'],
      }
    }
  }
}
