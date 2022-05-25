# Installs and configures the octavia controller profile.
class ntnuopenstack::octavia {
  include ::ntnuopenstack::octavia::api
  include ::ntnuopenstack::octavia::certs
  include ::ntnuopenstack::octavia::controller
  include ::ntnuopenstack::octavia::logging
  include ::ntnuopenstack::octavia::quota
  require ::ntnuopenstack::repo
}
