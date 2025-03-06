# Defines the databases used by openstack
class ntnuopenstack::databases {
  $zabbixpw = lookup('ntnuopenstack::zabbix::database::password', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })

  # Create databases for the openstack-services needed in the current cluster.
  # A database is created if that services database password is provided in
  # hiera, and if the service belongs in this clusters role, being region-
  # specific, common services, or all combined in single region clouds.
  $services_region = ['barbican', 'cinder', 'glance', 'heat',
    'magnum', 'neutron', 'nova', 'octavia', 'placement', ]
  $services_common = ['designate', 'keystone']

  $mysqlrole = lookup('profile::mysql::serverrole', {
    'default_value' => 'combined',
    'value_type'    =>  Enum['combined', 'region', 'common']
  }

  $services = $mysqlrole ? {
    'combined' => $services_region + $services_common,
    'region'   => $services_region,
    'common'   => $services_common,
  }

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
