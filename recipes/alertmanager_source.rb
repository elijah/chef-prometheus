#
# Cookbook Name:: prometheus
# Recipe:: alertmanager_source
#
# Author: Javier Zunzunegui <javier.zunzunegui.b@gmail.com>
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

# These packages are needed go build
%w(curl git-core mercurial gzip sed).each do |pkg|
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
