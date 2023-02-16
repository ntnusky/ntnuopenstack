# Configures auth for the glance service. 
class ntnuopenstack::glance::auth {
  ::ntnuopenstack::common::authtoken { 'glance': }
}
