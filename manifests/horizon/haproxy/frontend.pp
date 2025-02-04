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
    $region = lookup('profile::haproxy::region', {
      'default_value' => $region_fallback,
      'value_type'    => String,
    })

    Haproxy::Balancermember <<| listening_service == 'bk_horizon' and
        tag == "region-${region}" |>>
  }

}
