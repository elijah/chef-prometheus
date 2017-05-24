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

directory node['prometheus']['alertmanager']['storage.path'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

# -- Write our Config -- #

template node['prometheus']['alertmanager']['config.file'] do
  cookbook  node['prometheus']['alertmanager']['config_cookbook_name']
  source    node['prometheus']['alertmanager']['config_template_name']
  mode      '0644'
  owner     node['prometheus']['user']
  group     node['prometheus']['group']
  variables(
    notification_config: node['prometheus']['alertmanager']['notification']
  )
  notifies  :restart, 'service[alertmanager]'
end

# -- Do the install -- #

include_recipe "prometheus::alertmanager_#{node['prometheus']['alertmanager']['install_method']}"

case node['prometheus']['init_style']
when 'runit'
  include_recipe 'runit::default'

  runit_service 'alertmanager' do
    default_logger true
  end
when 'bluepill'
  include_recipe 'bluepill::default'

  template "#{node['bluepill']['conf_dir']}/alertmanager.pill" do
    source 'alertmanager.pill.erb'
    mode '0644'
  end

  bluepill_service 'alertmanager' do
    action [:enable, :load]
  end
when 'systemd'
  # rubocop:disable Style/HashSyntax
  dist_dir, conf_dir, env_file = value_for_platform_family(
    ['fedora'] => %w(fedora sysconfig alertmanager),
    ['rhel'] => %w(redhat sysconfig alertmanager),
    ['debian'] => %w(debian default alertmanager)
  )

  template '/etc/systemd/system/alertmanager.service' do
    source 'systemd/alertmanager.service.erb'
    mode '0644'
    variables(:sysconfig_file => "/etc/#{conf_dir}/#{env_file}")
    notifies :restart, 'service[alertmanager]', :delayed
  end

  template "/etc/#{conf_dir}/#{env_file}" do
    source "#{dist_dir}/#{conf_dir}/alertmanager.erb"
    mode '0644'
    notifies :restart, 'service[alertmanager]', :delayed
  end

  service 'prometheus' do
    supports :status => true, :restart => true
    action [:enable, :start]
  end
  # rubocop:enable Style/HashSyntax
when 'upstart'
  template '/etc/init/alertmanager.conf' do
    source 'upstart/alertmanager.service.erb'
    mode '0644'
    notifies :restart, 'service[alertmanager]', :delayed
  end

  service 'alertmanager' do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
  end
else
  template '/etc/init.d/alertmanager' do
    source 'alertmanager.init.erb'
    owner 'root'
    group node['root_group']
    mode '0755'
    notifies :restart, 'service[alertmanager]', :delayed
  end
end

# rubocop:disable Style/HashSyntax
service 'alertmanager' do
  supports :status => true, :restart => true
end
# rubocop:enable Style/HashSyntax

service 'alertmanager' do
  action [:enable, :start]
end
