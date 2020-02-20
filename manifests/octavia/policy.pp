# Modifies the octavia policies to our taste :) 
class ntnuopenstack::octavia::policy {
  class { '::octavia::policy':
    policies => {
      'octavia-lb-flavor-get-all'        => {
        'key'   => 'os_load-balancer_api:flavor:get_all',
        'value' => 'rule:load-balancer:read',
      },
      'octavia-lb-flavor-get-one'        => {
        'key'   => 'os_load-balancer_api:flavor:get_one',
        'value' => 'rule:load-balancer:read',
      },
      'octavia-lb-flavorprofile-get-all' => {
        'key'   => 'os_load-balancer_api:flavor-profile:get_all',
        'value' => 'rule:load-balancer:read',
      },
      'octavia-lb-flavorprofile-get-one' => {
        'key'   => 'os_load-balancer_api:flavor-profile:get_one',
        'value' => 'rule:load-balancer:read',
      },
    },
  }
}
