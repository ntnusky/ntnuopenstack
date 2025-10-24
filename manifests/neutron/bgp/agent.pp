# Configures a neutron BGP agent
define ntnuopenstack::neutron::bgp::agent (
  $interface,
) {
  $bgpconf = "/etc/neutron/bgp_dragent_${name}.ini"
  $bgplog = "/var/log/neutron/neutron-bgp-dragent-${name}.log"

  $router_id = $::sl2['server']['interfaces'][$interface]['ipv4']

  $speaker_driver = lookup('ntnuopenstack::neutron::bgp::speaker::driver', {
    'default_value' => 
      'neutron_dynamic_routing.services.bgp.agent.driver.os_ken.driver.OsKenBgpDriver',
    'value_type'    => String,
  })

  $ensure = lookup('ntnuopenstack::neutron::bgp::agent::ensure', {
    'default_value' => 'running',
    'value_type'    => Enum['running', 'stopped'],
  })
  $enable = lookup('ntnuopenstack::neutron::bgp::agent::enable', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  service { "neutron-bgp-multiagent@${name}.service":
    ensure => $ensure,
    enable => $enable,
  }

  ini_setting { "BGP-Agent ${name} hostname":
    ensure  => present,
    path    => $bgpconf,
    section => 'DEFAULT',
    setting => 'host',
    value   => "${::hostname}-${name}",
    require => Package['neutron-bgp-dragent'],
    tag     => [
      'neutron-dragent-bgp-config',
      "neutron-dragent-bgp-config-${name}",
    ],
  }

  ini_setting { "BGP-Agent ${name} router-id":
    ensure  => present,
    path    => $bgpconf,
    section => 'bgp',
    setting => 'bgp_router_id',
    value   => $router_id,
    require => Package['neutron-bgp-dragent'],
    tag     => [
      'neutron-dragent-bgp-config',
      "neutron-dragent-bgp-config-${name}",
    ],
  }

  ini_setting { "BGP-Agent ${name} bgp_speaker_driver":
    ensure  => present,
    path    => $bgpconf,
    section => 'bgp',
    setting => 'bgp_speaker_driver',
    value   => $speaker_driver,
    require => Package['neutron-bgp-dragent'],
    tag     => [
      'neutron-dragent-bgp-config',
      "neutron-dragent-bgp-config-${name}",
    ],
  }
}
