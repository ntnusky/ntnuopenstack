# Configures neutron to connect to the external networks defined in the hiera
# files.
class ntnuopenstack::neutron::external {
  $external_networks = lookup('profile::neutron::external::networks', {
    'default_value' => [],
    'value_type'    => Array[String],
    'merge'         => 'unique',
  })

  require ::vswitch::ovs

  $external = $external_networks.each |$net| {
    $vlanid = lookup("profile::neutron::external::${net}::vlanid", Integer)
    $bridge = lookup("profile::neutron::external::${net}::bridge", String)
    $interface = lookup("profile::neutron::external::${net}::interface", String)

    if($vlanid == 0) {
      vs_port { $interface:
        ensure => present,
        bridge => $bridge,
      }
    } else {
      $n = "${interface}-${vlanid}-${bridge}"
      ::profile::infrastructure::ovs::patch { $n :
        physical_if => $interface,
        vlan_id     => $vlanid,
        ovs_bridge  => $bridge,
      }
    }
  }
}
