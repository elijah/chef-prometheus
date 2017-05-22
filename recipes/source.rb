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
include_recipe 'golang::default'

# These packages are needed go build
%w(curl git-core mercurial gzip sed).each do |pkg|
  package pkg
end

git "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}" do
  repository node['prometheus']['source']['git_repository']
  revision node['prometheus']['source']['git_revision']
  action :checkout
end

bash 'compile_prometheus_source' do
  cwd "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}"
  environment 'PATH' => "/usr/local/go/bin:#{ENV['PATH']}", 'GOPATH' => "/opt/go:#{node['go']['gopath']}:/opt/go/src/github.com/prometheus/promu/vendor"
  code <<-EOH
    make build &&
    mv prometheus #{node['prometheus']['dir']} &&
    cp -R console_libraries #{node['prometheus']['dir']} &&
    cp -R consoles #{node['prometheus']['dir']}
  EOH

  notifies :restart, 'service[prometheus]'
end
