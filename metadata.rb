# rubocop:disable Style/SingleSpaceBeforeFirstArg
name             'prometheus'
maintainer       'Ray Rodriguez'
maintainer_email 'rayrod2030@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures Prometheus'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.6.2'
# rubocop:enable Style/SingleSpaceBeforeFirstArg

%w( ubuntu debian centos redhat fedora ).each do |os|
  supports os
end

depends 'apt'
depends 'yum'
depends 'build-essential'
depends 'runit', '~> 1.5'
depends 'bluepill', '~> 2.3'
depends 'accumulator'
depends 'ark'
