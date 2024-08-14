# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::octavia::haproxy::backend {
  $if = lookup('profile::interfaces::management', {
    'default_value' => $::sl2['server']['primary_interface']['name'],
    'value_type'    => String,
  })
  $port = lookup('ntnuopenstack::octavia::api::port', Integer)

  ::profile::services::haproxy::backend { 'OctaviaPublic':
    backend   => 'bk_octavia_public',
    port      => $port,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'OctaviaAdmin':
    backend   => 'bk_octavia_admin',
    port      => $port,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
