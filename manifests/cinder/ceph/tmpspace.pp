# Creates a ceph image and mounts it so that cinder can store images there
# during conversions.
class ntnuopenstack::cinder::ceph::tmpspace {
  $tmpsize = lookup('ntnuopenstack::cinder::tmpspace::gigabytes', {
    'default_value' => 1000,
    'value_type'    => Integer,
  })

  include ::cinder::deps
  require ::profile::ceph::client

  $megabytes = 1024 * $tmpsize
  $imagename = "rbd/cinder-tmp-${::hostname}"
  exec { 'Create RBD tmpspace':
    command => "/usr/bin/rbd create --size ${megabytes} ${imagename}",
    unless  => "/usr/bin/rbd info ${imagename}",
  }

  ::profile::ceph::rbdmap { 'Cinder-tmpspace':
    image   => $imagename,
    keyring => '/etc/ceph/ceph.client.admin.keyring',
    user    => 'admin',
    require => Exec['Create RBD tmpspace'],
  }

  exec { 'Format the tmpspace':
    command => "/sbin/mkfs.ext4 /dev/rbd/${imagename}",
    unless  => "/sbin/blkid -t TYPE=ext4 /dev/rbd/${imagename}",
    require => [
      Profile::Ceph::Rbdmap['Cinder-tmpspace'],
      Service['rbdmap'],
    ],
  }

  mount { '/var/lib/cinder/conversion':
    ensure  => 'mounted',
    fstype  => 'ext4',
    options => 'nobootwait',
    device  => "/dev/rbd/${imagename}",
    require => Exec['Format the tmpspace'],
  }

  file { '/var/lib/cinder/conversion':
    ensure => directory,
    group  => 'cinder',
    owner  => 'cinder',
    mode   => '0750',
  }
}
