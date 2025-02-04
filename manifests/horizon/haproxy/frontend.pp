# Configures the haproxy frontend for horizon
class ntnuopenstack::horizon::haproxy::frontend {
  include ::profile::services::haproxy::web

  $collectall = lookup('profile::haproxy::collect::all', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  profile::services::haproxy::tools::collect { 'bk_horizon': }

  haproxy::backend { 'bk_horizon':
    collect_exported => false,
    mode             => 'http',
    options          => {
      'balance' => 'source',
      'option'  => [
        'httplog',
        'httpchk',
        'tcpka',
        'tcplog',
      ],
    },
  }

  if($collectall) {
    Haproxy::Balancermember <<| listening_service == 'bk_horizon' |>>
  } else {
    $region_fallback = lookup('profile::region', {
      'default_value' => undef,
      'value_type'    => Optional[String],
    })
    $overrides = lookup('profile::haproxy::region::override', {
      'default_value' => {},
      'value_type'    => Hash[String, Array[String]],
    })

    # If there is defined an override-list for a certain haproxy-backend, use
    # that list as the list of regions to collect servers from.
    if("bk_${name}" in $overrides) {
      $regions = [] + $overrides['bk_horizon']

    # Otherwise use the haproxy-servers region
    } else {
      $regions = [ $region_fallback ]
    }

    $regions.each | $region | {
      Haproxy::Balancermember <<| listening_service == 'bk_horizon' and
          tag == "region-${region}" |>>
    }
  }

}
