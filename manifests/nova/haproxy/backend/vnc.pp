# Exports a server-definition to be collected by the haproxy backends.
class ntnuopenstack::nova::haproxy::backend::vnc {
  $if = lookup('profile::interfaces::management')

  ::profile::services::haproxy::backend { 'NovaVNC':
    backend   => 'bk_nova_vnc',
    port      => '6080',
    interface => $if,
    options   => 'check inter 2000 rise 2 fall 5',
  }
}
