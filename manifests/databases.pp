# Defines the databases used by openstack
class ntnuopenstack::databases {
  $region = lookup('ntnuopenstack::region')
  $servicedata = lookup('ntnuopenstack::services', {
    'value_type' => Hash[String, Hash],
  })
  $zabbixpw = lookup('ntnuopenstack::zabbix::database::password', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  # Create databases for the openstack-services needed in the current region.
  # What services that are needed is determined by which services have gotten
  # data in hiera.
  $default_services = [ 'barbican', 'cinder', 'glance', 'heat', 'keystone', 
    'magnum', 'neutron', 'nova', 'octavia', 'placement', ]
  $services = lookup('ntnuopenstack::service::databases' {
    'default_value' => $default_services,
    'value_type'    => Array[String],
  })

  $services.each | $service | {
    if($region in $servicedata and $service in $servicedata[$region]['services']) {
      include "::ntnuopenstack::${service}::database"
    }
  }

  # If we are monitoring this platform with zabbix, create a user with
  # read-access to the databases for zabbix. 
  if($zabbixpw) {
    include ::ntnuopenstack::zabbix::database
  }
}
