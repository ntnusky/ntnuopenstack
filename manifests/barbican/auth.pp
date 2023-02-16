# Configures auth for barbican. 
class ntnuopenstack::barbican::auth {
  ::ntnuopenstack::common::authtoken { 'barbican': }
}
