# Designate RBAC Policy - To be imported in ::designate::policy and ::horizon::dashboards::designate
class ntnuopenstack::designate::policy {
  $designatePolicies = {
    # Only admins (not project members/owners) can create new zones
    'create_zone_admin_only' => {
      'key' => 'create_zone',
      'value' => 'role:admin',
    },
  }
}
