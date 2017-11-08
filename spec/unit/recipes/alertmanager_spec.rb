#
# Filename:: alertmanager_spec.rb
# Description:: Verifies alertmanager recipe(s).
#
# Author: Elijah Caine <elijah.caine.mv@gmail.com>
#

require 'spec_helper'

# Caution: This is a carbon-copy of default_spec.rb with some variable replacements.

# rubocop:disable Metrics/BlockLength
describe 'prometheus::alertmanager' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/tmp/chef/cache').converge(described_recipe)
  end

  before do
    stub_command('/usr/local/go/bin/go version | grep "go1.5 "').and_return(0)
  end

  it 'creates a user with correct attributes' do
    expect(chef_run).to create_user('prometheus').with(
      system: true,
      shell: '/bin/false',
      home: '/opt/prometheus'
    )
  end

  it 'creates a directory at /opt/prometheus' do
    expect(chef_run).to create_directory('/opt/prometheus').with(
      owner: 'prometheus',
      group: 'prometheus',
      mode: '0755',
      recursive: true
    )
  end

  it 'creates a directory at /var/log/prometheus' do
    expect(chef_run).to create_directory('/var/log/prometheus').with(
      owner: 'prometheus',
      group: 'prometheus',
      mode: '0755',
      recursive: true
    )
  end

  it 'renders a prometheus job configuration file and notifies prometheus to restart' do
    resource = chef_run.template('/opt/prometheus/alertmanager.conf')
    expect(resource).to notify('service[alertmanager]').to(:restart)
  end

  # Test for source.rb

  context 'source' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['alertmanager']['version'] = '0.6.2'
        node.set['prometheus']['alertmanager']['install_method'] = 'source'
      end.converge(described_recipe)
    end

    it 'includes build-essential' do
      expect(chef_run).to include_recipe('build-essential::default')
    end

    %w(curl git-core mercurial gzip sed).each do |pkg|
      it 'installs #{pkg}' do
        expect(chef_run).to install_package(pkg)
      end
    end

    it 'checks out alertmanager from github' do
      expect(chef_run).to checkout_git("#{Chef::Config[:file_cache_path]}/alertmanager-0.6.2").with(
        repository: 'https://github.com/prometheus/alertmanager.git',
        revision: '0.6.2'
      )
    end

    it 'compiles alertmanager source' do
      expect(chef_run).to run_bash('compile_alertmanager_source')
    end

    it 'notifies alertmanager to restart' do
      resource = chef_run.bash('compile_alertmanager_source')
      expect(resource).to notify('service[alertmanager]').to(:restart)
    end

    context 'runit' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'runit'
        end.converge(described_recipe)
      end

      it 'includes runit::default recipe' do
        expect(chef_run).to include_recipe('runit::default')
      end

      it 'enables runit_service' do
        expect(chef_run).to enable_runit_service('alertmanager')
      end
    end

    context 'bluepill' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'bluepill'
        end.converge(described_recipe)
      end

      it 'includes bluepill::default recipe' do
        expect(chef_run).to include_recipe('bluepill::default')
      end

      it 'renders a bluepill configuration file' do
        expect(chef_run).to render_file("#{chef_run.node['bluepill']['conf_dir']}/alertmanager.pill")
      end
    end

    context 'init' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'init'
        end.converge(described_recipe)
      end

      it 'renders an init.d configuration file' do
        expect(chef_run).to render_file('/etc/init.d/alertmanager')
      end
    end

    context 'systemd' do
      unit_file = '/etc/systemd/system/alertmanager.service'

      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'systemd'
          node.set['prometheus']['user'] = 'prom_user'
          node.set['prometheus']['group'] = 'prom_group'
          node.set['prometheus']['alertmanager']['binary'] = '/tmp/alertmanager'
          node.set['prometheus']['alertmanager']['storage.path'] = '/tmp/alertmanager_data'
          node.set['prometheus']['alertmanager']['config.file'] = '/tmp/alertmanager.conf'
          node.set['prometheus']['flags']['alertmanager.url'] = 'http://0.0.0.0:8080'
        end.converge(described_recipe)
      end

      it 'renders a systemd service file' do
        expect(chef_run).to render_file(unit_file)
      end

      it 'renders systemd unit with custom variables' do
        expect(chef_run).to render_file(unit_file).with_content { |content|
          expect(content).to include('ExecStart=/tmp/alertmanager')
          expect(content).to include('-storage.path=/tmp/alertmanager_data \\')
          expect(content).to include('-config.file=/tmp/alertmanager.conf \\')
          expect(content).to include('-web.external-url=http://0.0.0.0:8080')
          expect(content).to include('User=prom_user')
          expect(content).to include('Group=prom_group')
        }
      end
    end

    context 'upstart' do
      job_file = '/etc/init/alertmanager.conf'

      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'upstart'
          node.set['prometheus']['user'] = 'prom_user'
          node.set['prometheus']['group'] = 'prom_group'
          node.set['prometheus']['alertmanager']['binary'] = '/tmp/alertmanager'
          node.set['prometheus']['alertmanager']['storage.path'] = '/tmp/alertmanager_data'
          node.set['prometheus']['alertmanager']['config.file'] = '/tmp/alertmanager.conf'
          node.set['prometheus']['flags']['alertmanager.url'] = 'http://0.0.0.0:8080'
          node.set['prometheus']['log_dir'] = '/tmp'
        end.converge(described_recipe)
      end

      it 'renders an upstart job configuration file' do
        expect(chef_run).to render_file(job_file)
      end

      it 'renders an upstart job configuration with custom variables' do
        expect(chef_run).to render_file(job_file).with_content { |content|
          expect(content).to include('setuid prom_user')
          expect(content).to include('setgid prom_group')
          expect(content).to include('exec >> "/tmp/alertmanager.log"')
          expect(content).to include('exec /tmp/alertmanager')
          expect(content).to include('-storage.path=/tmp/alertmanager_data')
          expect(content).to include('-config.file=/tmp/alertmanager.conf')
          expect(content).to include('-web.external-url=http://0.0.0.0:8080')
        }
      end
    end
  end

  # Test for binary.rb

  context 'binary' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['alertmanager']['version'] = '0.6.2'
        node.set['prometheus']['alertmanager']['install_method'] = 'binary'
      end.converge(described_recipe)
    end

    it 'runs ark with correct attributes' do
      expect(chef_run).to put_ark('prometheus').with(
        url: 'https://github.com/prometheus/alertmanager/releases/download/v0.6.2/alertmanager-0.6.2.linux-amd64.tar.gz',
        checksum: '8b796592b974a1aa51cac4e087071794989ecc957d4e90025d437b4f7cad214a',
        version: '0.6.2',
        prefix_root: Chef::Config['file_cache_path'],
        path: '/opt',
        owner: 'prometheus',
        group: 'prometheus'
      )
    end

    it 'runs ark with given file_extension' do
      chef_run.node.set['prometheus']['alertmanager']['file_extension'] = 'tar.gz'
      chef_run.converge(described_recipe)
      expect(chef_run).to put_ark('prometheus').with(
        extension: 'tar.gz'
      )
    end

    context 'runit' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'runit'
          node.set['prometheus']['alertmanager']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'includes runit::default recipe' do
        expect(chef_run).to include_recipe('runit::default')
      end

      it 'enables runit_service' do
        expect(chef_run).to enable_runit_service('alertmanager')
      end
    end

    context 'bluepill' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'bluepill'
          node.set['prometheus']['alertmanager']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'includes bluepill::default recipe' do
        expect(chef_run).to include_recipe('bluepill::default')
      end

      it 'renders a bluepill configuration file' do
        expect(chef_run).to render_file("#{chef_run.node['bluepill']['conf_dir']}/alertmanager.pill")
      end
    end

    context 'init' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'init'
          node.set['prometheus']['alertmanager']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders an init.d configuration file' do
        expect(chef_run).to render_file('/etc/init.d/alertmanager')
      end
    end

    context 'systemd' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'systemd'
          node.set['prometheus']['alertmanager']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders a systemd service file' do
        expect(chef_run).to render_file('/etc/systemd/system/alertmanager.service')
      end
    end
    context 'upstart' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'upstart'
          node.set['prometheus']['alertmanager']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders an upstart job configuration file' do
        expect(chef_run).to render_file('/etc/init/alertmanager.conf')
      end
    end
  end
end
