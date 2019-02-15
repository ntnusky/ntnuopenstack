# Configures the neutron endpoint in keystone
class ntnuopenstack::neutron::endpoint {
  # Openstack settings
  $region = lookup('ntnuopenstack::region', String)
  $keystone_password = lookup('ntnuopenstack::neutron::keystone::password',
                                String)

  # Determine the endpoint addresses
  $neutron_admin    = lookup('ntnuopenstack::neutron::endpoint::admin',
                                Stdlib::Httpurl)
  $neutron_internal = lookup('ntnuopenstack::neutron::endpoint::internal',
                                Stdlib::Httpurl)
  $neutron_public   = lookup('ntnuopenstack::neutron::endpoint::public',
                                Stdlib::Httpurl)

  # Configure the neutron API endpoint in keystone
  class { '::neutron::keystone::auth':
    password     => $keystone_password,
    public_url   => "${neutron_public}:9696",
    internal_url => "${neutron_internal}:9696",
    admin_url    => "${neutron_admin}:9696",
    region       => $region,
  }
}
