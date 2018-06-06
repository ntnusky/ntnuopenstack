# Installs and configures the cinder service on an openstack controller node in
# the SkyHiGh architecture
class ntnuopenstack::cinder {
  contain ::ntnuopenstack::cinder::api
  contain ::ntnuopenstack::cinder::scheduler
  contain ::ntnuopenstack::cinder::volume
}
