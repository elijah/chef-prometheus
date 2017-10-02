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

directory node['prometheus']['flags']['storage.local.path'] do
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0755'
  recursive true
end

apt_update 'please'
# Ensure that any unpacking of prometheus doesn't blow away our own configuration
include_recipe "prometheus::#{node['prometheus']['install_method']}"

# -- Write our Config -- #

#template node['prometheus']['flags']['config.file'] do
#  action    :nothing
#  cookbook  node['prometheus']['job_config_cookbook_name']
#  source    node['prometheus']['job_config_template_name']
#  mode      '0644'
#  owner     node['prometheus']['user']
#  group     node['prometheus']['group']
#  variables(
#    rule_filenames: node['prometheus']['rule_filenames']
#  )
#  notifies  :reload, 'service[prometheus]'
#end

# monitor our server instance
#prometheus_job 'prometheus' do
#  scrape_interval   '15s'
#  target            "localhost#{node['prometheus']['flags']['web.listen-address']}"
#  metrics_path      node['prometheus']['flags']['web.telemetry-path']
#end

# -- Do the install -- #

include_recipe 'prometheus::service'
