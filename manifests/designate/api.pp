# Installs the designate API.
class ntnuopenstack::designate::api {
  $api_port = lookup('ntnuopenstack::designate::api::port')

  require ::ntnuopenstack::designate::base
  require ::ntnuopenstack::designate::auth

  class { '::designate::api':
    auth_strategy    => 'keystone',
    enable_api_v2    => true,
    enable_api_admin => true,
    api_base_uri     => 'httpd',
  }

  class { '::designate::wsgi::apache':
    access_log_format => 'forwarded',
    workers           => 2,
    port              => Integer($api_port),
  }
}
