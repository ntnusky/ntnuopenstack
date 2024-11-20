# Configures the haproxy frontend for the public swift API, if the swift-api is
# placed on a dedicated name at port 80/443.
class ntnuopenstack::swift::haproxy::web {
  $collectall = lookup('profile::haproxy::collect::all', {
    'default_value' => true,
    'value_type'    => Boolean,
  })

  include ::profile::services::haproxy::web

  profile::services::haproxy::tools::collect { 'bk_swift_public': }

  haproxy::backend { 'bk_swift_public':
    collect_exported => false,
    mode             => 'http',
    options          => {
      'balance' => 'source',
      'option'  => [
        'httpchk HEAD /',
        'forwardfor',
        'http-server-close',
      ],
      'timeout' => [
        'http-keep-alive 500',
      ],
    },
  }

  if($collectall) {
    Haproxy::Balancermember <<| listening_service == 'bk_swift_public' |>>
  } else {
    $region = lookup('ntnuopenstack::region', {
      'default_value' => undef,
      'value_type'    => Optional[String],
    })

    Haproxy::Balancermember <<| listening_service == 'bk_swift_public' and
        tag == "region-${region}" |>>
  }
}
