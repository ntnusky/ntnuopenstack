# Defines the databases used by openstack
class ntnuopenstack::databases {
  $zabbixpw = lookup('ntnuopenstack::zabbix::database::password', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  # Create databases for the openstack-services needed in the current region.
  # What services that are needed is determined by which services have gotten a
  # database password in hiera.
  $services = ['barbican', 'cinder', 'glance', 'heat', 'keystone', 'magnum',
    'neutron', 'nova', 'octavia', 'placement', ]
  $services.each | $service | {
    $password = lookup("ntnuopenstack::${service}::mysql::password", {
      'default_value' => undef,
      'value_type'    => Optional[String],
    })
    if($password) {
      include "::ntnuopenstack::${service}::database"
    }
  }

  # If we are monitoring this platform with zabbix, ensure 
  if($zabbixpw) {
    include ::ntnuopenstack::zabbix::database
  }
}
