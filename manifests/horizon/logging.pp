# Configures logging for horizon 
class ntnuopenstack::horizon::logging {
  # Most of the logs are from apache
  include ::profile::services::apache::logging

  # Some might also come in the regular 'openstack paths'
  ntnuopenstack::common::logging { 'horizon':
    project => 'horizon',
  }

  logrotate::rule { 'openstack-dashboard':
    path         => '/var/log/horizon/*.log',
    rotate       => 4,
    rotate_every => 'week',
    compress     => true,
    copytruncate => true,
    missingok    => true,
  }
}
