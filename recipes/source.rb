#
# Cookbook Name:: prometheus
# Recipe:: default
#
# Author: Ray Rodriguez <rayrod2030@gmail.com>
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

if node['prometheus']['source']['use_existing_user'] == false
  prometheus_user = node['prometheus']['source']['user']
  prometheus_group = node['prometheus']['source']['group']
else
  prometheus_user = 'root'
  prometheus_group = node['root_group']
end

user prometheus_user do
  system true
  shell '/bin/false'
  home node['prometheus']['dir']
  only_if { node['prometheus']['source']['use_existing_user'] == false }
end

directory node['prometheus']['dir'] do
  owner prometheus_user
  group prometheus_group
  mode '0755'
  recursive true
end

# These packages are needed go build
%w( curl git-core mercurial gzip sed ).each do |pkg|
  package pkg
end

git "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['source']['version']}" do
  repository node['prometheus']['source']['git_repository']
  revision node['prometheus']['source']['git_revision']
  action :checkout
end

bash 'compile_prometheus_source' do
  cwd "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['source']['version']}"
  code <<-EOH
    make build &&
    cp -R prometheus #{node['prometheus']['dir']} &&
    cp -R console_libraries #{node['prometheus']['dir']} &&
    cp -R consoles #{node['prometheus']['dir']}
  EOH

  not_if do
    File.exist?("#{node['prometheus']['dir']}/prometheus")
  end

  notifies :restart, 'service[prometheus]'
end

template node['prometheus']['flags']['config.file'] do
  cookbook node['prometheus']['job_config_cookbook_name']
  source node['prometheus']['job_config_template_name']
  mode 0644
  owner prometheus_user
  group prometheus_group
  notifies :restart, 'service[prometheus]'
end

directory node['prometheus']['log_dir'] do
  owner prometheus_user
  group prometheus_group
  mode '0755'
  recursive true
end

case node['prometheus']['init_style']
when 'runit'
  include_recipe 'runit::default'

  runit_service 'prometheus' do
    default_logger true
  end
when 'bluepill'
  include_recipe 'bluepill::default'

  template "#{node['bluepill']['conf_dir']}/prometheus.pill" do
    source 'prometheus.pill.erb'
    mode 0644
  end

  bluepill_service 'prometheus' do
    action [:enable, :load]
  end
else
  template '/etc/init.d/prometheus' do
    source "#{node['platform']}/prometheus.erb"
    owner 'root'
    group node['root_group']
    mode '0755'
    notifies :restart, 'service[prometheus]', :delayed
  end
end

# rubocop:disable Style/HashSyntax
service 'prometheus' do
  supports :status => true, :restart => true
end
# rubocop:enable Style/HashSyntax
