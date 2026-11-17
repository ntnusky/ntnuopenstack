# Configures the nova hypervisor ID
class ntnuopenstack::nova::compute::id {

  include ::nova::deps

  $ids = lookup('ntnuopenstack::nova::compute::ids', {
    'value_type' => Hash[String, String],
  })

  if(! ($::facts['networking']['fqdn'] in $ids)) {
    fail(join([
      "The hostname ${::facts['networking']['fqdn']} is missing in the",
      "'ntnuopenstack::nova::compute::ids' key in hiera",
    ], ' '))
  }

  file { '/var/lib/nova/compute_id':
    ensure  => 'file',
    content => $ids[$::facts['networking']['fqdn']],
    group   => 'nova',
    owner   => 'nova',
    mode    => '0640',
    require => Anchor['nova::install::end'],
  }
}
