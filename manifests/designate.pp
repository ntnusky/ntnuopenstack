# Installs and configures the designate DNSaaS Provider
class ntnuopenstack::designate {
  include ::ntnuopenstack::designate::api
  include ::ntnuopenstack::designate::backend
  require ::ntnuopenstack::repo
}
