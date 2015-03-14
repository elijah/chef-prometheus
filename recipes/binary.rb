#
# Cookbook Name:: prometheus
# Recipe:: binary
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

src_filepath = "#{Chef::Config['file_cache_path']}/prometheus-#{node['prometheus']['version']}.tar.bz2"
extract_path = node['prometheus']['dir']
file_name = ::File.basename(node['prometheus']['binary'])

remote_file src_filepath do
  mode '0644'
  source node['prometheus']['binary_url']
  checksum node['prometheus']['checksum']
  action :create_if_missing
end

execute 'extract prometheus' do
  command "tar -xjf #{src_filepath} -C #{extract_path}"
  not_if "test -d #{extract_path}/#{file_name}"
end
