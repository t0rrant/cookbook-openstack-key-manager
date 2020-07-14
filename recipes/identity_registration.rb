# encoding: UTF-8
#
# Cookbook Name:: openstack-key-manager
# Recipe:: identity_registration
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
#

require 'uri'
# Make Openstack object available in Chef::Recipe
class ::Chef::Recipe
  include ::Openstack
end

identity_endpoint = internal_endpoint 'identity'
auth_url = ::URI.decode identity_endpoint.to_s

interfaces = {
    public: { url: public_endpoint('key-manager') },
    internal: { url: internal_endpoint('key-manager') },
    admin: { url: admin_endpoint('key-manager') },
}
service_pass = get_password 'service', 'openstack-key-manager'
region = node['openstack']['key-manager']['region']
service_project_name = node['openstack']['key-manager']['conf']['keystone_authtoken']['project_name']
service_user = node['openstack']['key-manager']['service_user']
admin_user = node['openstack']['identity']['admin_user']
admin_pass = get_password 'user', node['openstack']['identity']['admin_user']
admin_project = node['openstack']['identity']['admin_project']
admin_domain = node['openstack']['identity']['admin_domain_name']
service_domain_name = node['openstack']['key-manager']['conf']['keystone_authtoken']['user_domain_name']
service_role = node['openstack']['key-manager']['service_role']
service_name = node['openstack']['key-manager']['service_name']
service_type = node['openstack']['key-manager']['service_type']

connection_params = {
    openstack_auth_url:     auth_url,
    openstack_username:     admin_user,
    openstack_api_key:      admin_pass,
    openstack_project_name: admin_project,
    openstack_domain_name:  admin_domain,
}

# Register Key Manager Service
openstack_service service_name do
  type service_type
  connection_params connection_params
end

interfaces.each do |interface, res|
  # Register Key Manager Endpoints
  openstack_endpoint service_type do
    service_name service_name
    interface interface.to_s
    url res[:url].to_s
    region region
    connection_params connection_params
  end
end

# Register Service Project
openstack_project service_project_name do
  connection_params connection_params
end

# Register Service User
openstack_user service_user do
  project_name service_project_name
  domain_name service_domain_name
  role_name service_role
  password service_pass
  connection_params connection_params
  action [:create, :grant_role]
end
