# Installs and configures the glance service on an openstack controller node in
# the SkyHiGh architecture
class ntnuopenstack::glance {
  contain ::ntnuopenstack::glance::api
}
