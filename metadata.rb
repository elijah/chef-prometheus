name             'prometheus'
maintainer       'Elijah Wright'
maintainer_email 'elijah.wright@gmail.com'
license          'Apache-2.0'
description      'Installs/Configures Prometheus'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.6.5'
source_url 'https://github.com/elijah/chef-prometheus'
issues_url 'https://github.com/elijah/chef-prometheus/issues'
chef_version '>= 12.15.25' if respond_to?(:chef_version)

%w(ubuntu debian centos redhat fedora).each do |os|
  supports os
end

depends 'apt'
depends 'yum'
depends 'build-essential'
depends 'runit', '>= 1.5'
depends 'ark'
depends 'golang'
depends 'compat_resource'

# this should really be a suggests
depends 'bluepill', '~> 2.3'
