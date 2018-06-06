# This class installs the neutron agents needed on a compute-node.
class ntnuopenstack::neutron::compute {
  require ::ntnuopenstack::repo

  require ::ntnuopenstack::neutron::tenant
}
