# Configures a haproxy server for horizon.
class ntnuopenstack::horizon::haproxy::backend {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $ip = $::facts['networking']['interfaces'][$if]['ip']

  profile::services::haproxy::tools::register { "Horizon-${::hostname}":
    servername  => $::hostname,
    backendname => 'bk_horizon',
  }

  $region_fallback = lookup('profile::region', {
    'default_value' => undef,
    'value_type'    => Optional[String],
  })
  $region = lookup('profile::haproxy::region', {
    'default_value' => $region_fallback,
    'value_type'    => Optional[String],
  })

  if($region) {
    $tags = ["region-${region}"]
  } else {
    $tags = []
  }

  @@haproxy::balancermember { "horizon-${::fqdn}":
    listening_service => 'bk_horizon',
    server_names      => $::hostname,
    ipaddresses       => $ip,
    ports             => '80',
    options           => 'check inter 2000 rise 2 fall 5',
    tag               => $tags,
  }
}
