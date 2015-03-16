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

file_ext = node['prometheus']['file_extension']
src_filepath = "#{Chef::Config['file_cache_path']}/prometheus-#{node['prometheus']['version']}.#{file_ext}"
extract_path = node['prometheus']['dir']

tar_flags =
case file_ext
when /^(tar.bz2|tbz)$/
  'xjf'
when /^(tar.gz|tgz)$/
  'xzf'
when /^(tar.xz|txz)$/
  'xJf'
when /^(tar)$/
  'xf'
end

remote_file src_filepath do
  mode '0644'
  source node['prometheus']['binary_url']
  checksum node['prometheus']['checksum']
  action :create
  notifies :run, 'execute[extract prometheus]', :immediately
end

execute 'extract prometheus' do
  command "tar -#{tar_flags} #{src_filepath} -C #{extract_path}"
  action :nothing
end
