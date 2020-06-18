# Configure nova-compute to expose a vGPU
# This is just a mechanism to ensure that this key is actually defined,
# and otherwise fail the puppet run.
class ntnuopenstack::nova::vgpu {
  $vgpu_type = lookup('nova::compute::vgpu::enabled_vgpu_types', String)
}
