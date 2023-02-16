# Configures heat's authtoken 
class ntnuopenstack::heat::auth {
  $internal_endpoint = lookup('ntnuopenstack::endpoint::internal')
  $password = lookup('ntnuopenstack::heat::keystone::password')

  ::ntnuopenstack::common::authtoken { 'heat': }

  class { '::heat::trustee':
    auth_url => "${internal_endpoint}:5000/",
    password => $password,
  }

}
