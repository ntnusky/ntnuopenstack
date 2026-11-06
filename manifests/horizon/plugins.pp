# Installs extra dashboards for horizon
class ntnuopenstack::horizon::plugins {
  $services = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash[String, Variant[Hash, String]]],
  })

  # NOTE: To fully disable a dashboard, dashboard: false must be set inn ALL regions
  # in the services construct in hiera
  # This logic will default to true if the dashboard key doesn't exists for a given service
  # (because looking up a non-existent key is undef and that's not equal to false)
  $services.each | $region, $data | {
    if('heat' in $data['services'] and ($data['services']['heat']['dashboard'] != false) ) {
      include ::horizon::dashboards::heat
    }
    if('octavia' in $data['services'] and ($data['services']['octavia']['dashboard'] != false) )  {
      include ::horizon::dashboards::octavia
    }
    if('designate' in $data['services'] and ($data['services']['designate']['dashboard'] != false) ) {
      include ::horizon::dashboards::designate
    }
  }

  # TODO: Remove this when Magnum is completly removed
  ensure_packages('python3-magnum-ui', {
    'ensure' => 'absent',
    'tag'    => ['horizon-package']
  })
}
