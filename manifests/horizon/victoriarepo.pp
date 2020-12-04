# A hack to add the Victoria-repo alongside the Ussuri repo
# This can be removed when upgrading to Victoria
# python3-swiftclient is broken in Ussuri, so we need to install
# it from the Victoria-repo

class ntnuopenstack::horizon::victoriarepo {
  yumrepo { 'rdo-release-victoria':
    ensure      => 'present',
    name        => 'OpenStack Victoria Repository',
    baseurl     => 'http://mirror.centos.org/centos/8/cloud/$basearch/openstack-victoria/',
    gpgkey      => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud',
    enabled     => '1',
    gpgcheck    => '1',
    includepkgs => 'python3-swiftclient',
  }
}
