# Configure nova-compute to expose a vGPU
class ntnuopenstack::nova::vgpu {
  $vgpu_type = lookup('ntnuopenstack::nova::vgpu::type', String)

  class { '::nova::compute::vgpu':
    enabled_vgpu_types => $vgpu_type,
  }
}
