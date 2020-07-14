platform_options = node['openstack']['key-manager']['platform']

platform_options['barbican_client_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']
    action :upgrade
  end
end
