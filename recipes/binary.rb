#
# Cookbook Name:: prometheus
# Recipe:: binary
#
# Author: Kristian Jarvenpaa <kristian.jarvenpaa@gmail.com>
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

include_recipe 'ark::default'

%w( curl tar bzip2 ).each do |pkg|
  package pkg
end

dir_name = ::File.basename(node['prometheus']['dir'])
dir_path = ::File.dirname(node['prometheus']['dir'])

ark dir_name do
  url node['prometheus']['binary_url']
  checksum node['prometheus']['checksum']
  version node['prometheus']['version']
  prefix_root Chef::Config['file_cache_path']
  path dir_path
  owner node['prometheus']['user']
  group node['prometheus']['group']
  extension node['prometheus']['file_extension'] unless node['prometheus']['file_extension'].empty?
  action :put
end
