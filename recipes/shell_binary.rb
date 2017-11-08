#
# Cookbook Name:: prometheus
# Recipe:: shell_binary
#
# Author: Rohit Gupta - @rohit01
#
# This recipie is similar to binary.rb without 'ark' dependency
#

%w(curl tar bzip2).each do |pkg|
  package pkg
end

bash 'download_prometheus' do
  code <<-EOH
    pfilename="#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}.tar.gz"
    curl -L -o "${pfilename}" "#{node['prometheus']['binary_url']}"
    chksum="$(shasum -b -a 256 ${pfilename} | awk '{print $1}')"
    if [ "${chksum}" != "#{node['prometheus']['checksum']}" ]; then
      echo "ERROR: Downloaded file checksum mismatch. Aborting!"
      exit 1
    fi
  EOH
  user     'root'
  group    'root'
  creates  "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}.tar.gz"
  action   :run
  notifies :run, 'bash[install_prometheus]', :immediately
end

bash 'install_prometheus' do
  code <<-EOH
    mkdir -p "#{node['prometheus']['dir']}"
    tar -xzf "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}.tar.gz" -C "#{node['prometheus']['dir']}" --strip-components=1
  EOH
  user     'root'
  group    'root'
  action   :nothing
  notifies :restart, 'service[prometheus]'
end
