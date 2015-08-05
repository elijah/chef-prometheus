#
# Cookbook Name:: prometheus
# Recipe:: alertmanager
#
# Author: Paul Magrath <paul@paulmagrath.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'build-essential::default'

user node['prometheus']['user'] do
  system true
  shell '/bin/false'
  home node['prometheus']['dir']
  not_if { node['prometheus']['use_existing_user'] == true || node['prometheus']['user'] == 'root' }
end

directory node['prometheus']['dir'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

directory node['prometheus']['log_dir'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

# -- Write our Config -- #

template node['prometheus']['alertmanager']['config.file'] do
  cookbook  node['prometheus']['alertmanager']['config_cookbook_name']
  source    node['prometheus']['alertmanager']['config_template_name']
  mode      0644
  owner     node['prometheus']['user']
  group     node['prometheus']['group']
  notifies  :restart, 'service[alertmanager]'
end

# -- Do the install -- #

# These packages are needed go build
%w( curl git-core mercurial gzip sed ).each do |pkg|
  package pkg
end

git "#{Chef::Config[:file_cache_path]}/alertmanager-#{node['prometheus']['alertmanager']['version']}" do
  repository node['prometheus']['alertmanager']['git_repository']
  revision node['prometheus']['alertmanager']['git_revision']
  action :checkout
end

bash 'compile_alertmanager_source' do
  cwd "#{Chef::Config[:file_cache_path]}/alertmanager-#{node['prometheus']['alertmanager']['version']}"
  code "make && mv alertmanager #{node['prometheus']['dir']}"

  notifies :restart, 'service[alertmanager]'
end

template '/etc/init/alertmanager.conf' do
  source 'upstart/alertmanager.service.erb'
  mode 0644
  notifies :restart, 'service[alertmanager]', :delayed
end

service 'alertmanager' do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end

# rubocop:disable Style/HashSyntax
service 'alertmanager' do
  supports :status => true, :restart => true
end
# rubocop:enable Style/HashSyntax
