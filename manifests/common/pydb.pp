# This class installs the python3 mysql-bindings
class ntnuopenstack::common::pydb {
  ensure_packages ( [ 'python3-mysqldb' ], {
    'ensure' => 'present',
  })
}
