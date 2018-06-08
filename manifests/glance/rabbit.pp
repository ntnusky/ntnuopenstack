# Glance rabbit configuration 
class ntnuopenstack::glance::rabbit {
  $transport_url = hiera('ntnuopenstack::transport::url')

  class { '::glance::notify::rabbitmq':
    default_transport_url => $transport_url,
  }
}
