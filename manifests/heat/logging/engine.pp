# Configures logging for heat 
class ntnuopenstack::heat::logging::engine {
  ntnuopenstack::common::logging { 'heat-engine':
    project => 'heat',
  }
}
