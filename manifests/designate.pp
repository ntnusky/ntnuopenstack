# Installs and configures the designate DNSaaS Provider
class ntnuopenstack::designate {
  include ::ntnuopenstack::designate::api
  include ::ntnuopenstack::designate::backend
  include ::ntnuopenstack::designate::base
  require ::ntnuopenstack::repo
}
