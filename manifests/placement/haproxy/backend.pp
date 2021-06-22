# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::placement::haproxy::backend {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'PlacementPublic':
    backend   => 'bk_placement_public',
    port      => 8778,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }

  ::profile::services::haproxy::backend { 'PlacementAdmin':
    backend   => 'bk_placement_admin',
    port      => 8778,
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
