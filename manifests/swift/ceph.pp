# Configures ceph for swift use
class ntnuopenstack::swift::ceph {
  require ::profile::ceph::client
}
