# Configures the nova hypervisor ID
class ntnuopenstack::nova::compute::id {
  $ids = lookup('ntnuopenstack::nova::compute::ids', {
    'value_type' => Hash[String, String],
  })

  if(! ($::fqdn in $ids)) {
    fail(join([
      "The hostname ${::fqdn} is missing in the",
      "'ntnuopenstack::nova::compute::ids' key in hiera",
    ], ' '))
  }

  file { '/var/lib/nova/compute_id':
    ensure  => 'file',
    content => $ids[$::fqdn],
    group   => 'nova',
    owner   => 'nova',
    mode    => '0640',
  }
}
