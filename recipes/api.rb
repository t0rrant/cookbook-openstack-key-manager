#
# Cookbook:: openstack-key-manager
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright:: 2020, Manuel Torrinha
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'uri'

class ::Chef::Recipe
  include ::Openstack
end

if node['openstack']['key-manager']['syslog']['use']
  include_recipe 'openstack-common::logging'
end

platform_options = node['openstack']['key-manager']['platform']

db_user = node['openstack']['db']['key-manager']['username']
db_pass = get_password 'db', 'barbican'
node.default['openstack']['key-manager']['conf_secrets']
.[]('DEFAULT')['sql_connection'] =
  db_uri('key-manager', db_user, db_pass)


if node['openstack']['mq']['service_type'] == 'rabbit'
  node.default['openstack']['key-manager']['conf_secrets']['DEFAULT']['transport_url'] = rabbit_transport_url 'key-manager'
end

bind_service = node['openstack']['bind_service']['all']['key-manager']
identity_endpoint = internal_endpoint 'identity'
node.default['openstack']['key-manager']['conf_secrets']
    .[]('keystone_authtoken')['password'] =
  get_password 'service', 'openstack-key-manager'

auth_url = ::URI.decode identity_endpoint.to_s

# TODO: review when adding debian support
# create file to prevent installation of non-working configuration
file '/etc/apache2/conf-available/barbican-wsgi.conf' do
  owner 'root'
  group 'www-data'
  mode '0640'
  action :create
  content '# Chef openstack-key-manager: file to block config from package'
  only_if { platform_family? 'debian' }
end

platform_options['barbican_api_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']
    action :upgrade
  end
end

directory '/etc/barbican' do
  group node['openstack']['key-manager']['group']
  owner node['openstack']['key-manager']['user']
  mode '750'
  action :create
end

node.default['openstack']['key-manager']['conf'].tap do |conf|
  conf['keystone_authtoken']['auth_url'] = auth_url
end

# merge all config options and secrets to be used in the barbican.conf.erb
barbican_conf_options = merge_config_options 'key-manager'

service 'barbican-apache2' do
  case node['platform_family']
  when 'debian'
    service_name 'apache2'
  when 'rhel'
    service_name 'httpd'
  end
  action :nothing
end

template '/etc/barbican/barbican.conf' do
  source 'openstack-service.conf.erb'
  cookbook 'openstack-common'
  group node['openstack']['key-manager']['group']
  owner node['openstack']['key-manager']['user']
  mode '640'
  variables(
      service_config: barbican_conf_options
    )
  notifies :restart, 'service[barbican-apache2]'
end

# delete all secrets saved in the attribute
# node['openstack']['key-manager']['conf_secrets'] after creating the barbican.conf
ruby_block "delete all attributes in node['openstack']['key-manager']['conf_secrets']" do
  block do
    node.rm(:openstack, :'key-manager', :conf_secrets)
  end
end

# Workaround lifted from openstack-dashboard::apache2-server to install apache2
# on a RHEL-ish machine with SELinux set to enforcing.
#
# TODO: once apache2 is in a place to allow for subscribes to web_app,
#       this workaround should go away
#
execute 'set-selinux-permissive' do
  command '/sbin/setenforce Permissive'
  action :run

  only_if "[ ! -e /etc/httpd/conf/httpd.conf ] && [ -e /etc/redhat-release ] && [ $(/sbin/sestatus | grep -c '^Current mode:.*enforcing') -eq 1 ]"
end

# include the logging recipe from openstack-common if syslog usage is enbaled
if node['openstack']['key-manager']['syslog']['use']
  include_recipe 'openstack-common::logging'
end

db_type = node['openstack']['db']['key-manager']['service_type']
node['openstack']['db']['python_packages'][db_type].each do |pkg|
  package pkg do
    action :upgrade
  end
end

execute 'barbican-manage db upgrade' do
  user node['openstack']['key-manager']['user']
  group node['openstack']['key-manager']['group']
end

# remove the barbican-wsgi.conf automatically generated from package
apache_config 'barbican-wsgi' do
  enable false
end

web_app 'barbican-api' do
  template 'wsgi-template.conf.erb'
  daemon_process 'barbican-api'
  server_host bind_service['host']
  server_port bind_service['port']
  server_entry '/usr/lib/python2.7/site-packages/barbican/api/app.wsgi'
  log_dir node['apache']['log_dir']
  run_dir node['apache']['run_dir']
  user node['openstack']['key-manager']['user']
  group node['openstack']['key-manager']['group']
  use_ssl node['openstack']['key-manager']['ssl']['enabled']
  cert_file node['openstack']['key-manager']['ssl']['certfile']
  chain_file node['openstack']['key-manager']['ssl']['chainfile']
  key_file node['openstack']['key-manager']['ssl']['keyfile']
  ca_certs_path node['openstack']['key-manager']['ssl']['ca_certs_path']
  cert_required node['openstack']['key-manager']['ssl']['cert_required']
  protocol node['openstack']['key-manager']['ssl']['protocol']
  ciphers node['openstack']['key-manager']['ssl']['ciphers']
end
