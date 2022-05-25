# Configures logging for a generic openstack service 
define ntnuopenstack::common::logging (
  String        $project,
  Array[String] $extra_paths = [],
){
  profile::utilities::logging::file { $name :
    paths     => [
      "/var/log/${project}/${name}.log",
    ] + $extra_paths,
    multiline => {
      'type'    => 'pattern',
      'pattern' => '^[0-9]{4}-[0-9]{2}-[0-9]{2}',
      'negate'  => 'true',
      'match'   => 'after',
    },
    tags      => [ 'openstack', $project, $name ],
  }
}
