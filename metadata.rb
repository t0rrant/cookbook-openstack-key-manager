name 'openstack-key-manager'
maintainer 'Manuel Torrinha'
maintainer_email 'manuel.torrinha@tecnico.ulisboa.pt'
license 'MIT'
description 'Installs/Configures OpenStack Key Manager service Barbican'
version '17.0.0'
chef_version '>= 12.5'

%w(ubuntu redhat centos).each do |os|
  supports os
end

issues_url 'https://github.com/t0rrant/cookbook-openstack-key-manager.git/issues'
source_url 'https://github.com/t0rrant/cookbook-openstack-key-manager'

depends 'openstack-common', '~> 17.0'

depends 'apache2', '< 6.0'
