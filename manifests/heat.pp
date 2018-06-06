# Installs and configures the heat service on an openstack controller node in
# the SkyHiGh architecture
class ntnuopenstack::heat {
  contain ::ntnuopenstack::heat::api
  contain ::ntnuopenstack::heat::engine
}
