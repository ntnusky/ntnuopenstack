# Configures logging for octavia
class ntnuopenstack::octavia::logging {
  # The API-service is logged through apache
  include ::profile::services::apache::logging

  # Some services runs standalone
  ntnuopenstack::common::logging { [
    'octavia-api',
    'octavia-health-manager',
    'octavia-housekeeping',
    'octavia-worker',
  ]:
    project => 'octavia',
  }
}
