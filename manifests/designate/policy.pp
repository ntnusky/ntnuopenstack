# Designate RBAC Policy
class ntnuopenstack::designate::policy {
  class {'::designate::policy':
    policies => {
      # Only admins (not project members/owners) can create new zones
      'create_zone_admin_only' => {
        'key' => 'create_zone',
        'value' => 'role:admin',
      },
    },
  }
}
