# rubocop:disable Style/SingleSpaceBeforeFirstArg
name             'prometheus'
maintainer       'Ray Rodriguez'
maintainer_email 'rayrod2030@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures Prometheus'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'
# rubocop:enable Style/SingleSpaceBeforeFirstArg

%w( ubuntu ).each do |os|
  supports os
end

depends 'apt'
depends 'build-essential'
depends 'runit', '~> 1.5'
depends 'bluepill', '~> 2.3'
