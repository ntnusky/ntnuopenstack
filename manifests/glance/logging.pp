# Configures logging for glance 
class ntnuopenstack::glance::logging {
  ntnuopenstack::common::logging { 'glance-api':
    project => 'glance',
  }
}
