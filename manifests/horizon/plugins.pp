# Installs extra dashboards for horizon
class ntnuopenstack::horizon::plugins {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  $services.each | $region, $data | {
    if('heat' in $data['services']) {
      include ::horizon::dashboards::heat
    }
    if('octavia' in $data['services']) {
      include ::horizon::dashboards::octavia
    }
    if('designate' in $data['services']) {
      include ::horizon::dashboards::designate
    }
  }

  # TODO: Remove this when Magnum is completly removed
  ensure_packages('python3-magnum-ui', {
    'ensure' => 'absent',
    'tag'    => ['horizon-package']
  })
}
