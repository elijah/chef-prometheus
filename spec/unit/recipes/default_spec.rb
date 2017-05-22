require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'prometheus::default' do
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
    resource = chef_run.template('/opt/prometheus/prometheus.yml')
    expect(resource).to notify('service[prometheus]').to(:restart)
  end

  # Test for source.rb

  context 'source' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['version'] = '1.6.3'
        node.set['prometheus']['install_method'] = 'source'
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

    it 'checks out prometheus from github' do
      expect(chef_run).to checkout_git("#{Chef::Config[:file_cache_path]}/prometheus-1.6.3").with(
        repository: 'https://github.com/prometheus/prometheus.git',
        revision: 'v1.6.3'
      )
    end

    it 'compiles prometheus source' do
      expect(chef_run).to run_bash('compile_prometheus_source')
    end

    it 'notifies prometheus to restart' do
      resource = chef_run.bash('compile_prometheus_source')
      expect(resource).to notify('service[prometheus]').to(:restart)
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
        expect(chef_run).to enable_runit_service('prometheus')
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
        expect(chef_run).to render_file("#{chef_run.node['bluepill']['conf_dir']}/prometheus.pill")
      end
    end

    context 'init' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'init'
        end.converge(described_recipe)
      end

      it 'renders an init.d configuration file' do
        expect(chef_run).to render_file('/etc/init.d/prometheus')
      end
    end

    context 'systemd' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'systemd'
        end.converge(described_recipe)
      end

      it 'renders a systemd service file' do
        expect(chef_run).to render_file('/etc/systemd/system/prometheus.service')
      end
    end

    context 'upstart' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'upstart'
        end.converge(described_recipe)
      end

      it 'renders an upstart job configuration file' do
        expect(chef_run).to render_file('/etc/init/prometheus.conf')
      end
    end
  end

  # Test for binary.rb

  context 'binary' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
        node.set['prometheus']['version'] = '1.6.3'
        node.set['prometheus']['install_method'] = 'binary'
      end.converge(described_recipe)
    end

    it 'runs ark with correct attributes' do
      expect(chef_run).to put_ark('prometheus').with(
        url: 'https://github.com/prometheus/prometheus/releases/download/v1.6.3/prometheus-1.6.3.linux-amd64.tar.gz',
        checksum: 'bb4e3bf4c9cd2b30fc922e48ab584845739ed4aa50dea717ac76a56951e31b98',
        version: '1.6.3',
        prefix_root: Chef::Config['file_cache_path'],
        path: '/opt',
        owner: 'prometheus',
        group: 'prometheus'
      )
    end

    it 'runs ark with given file_extension' do
      chef_run.node.set['prometheus']['file_extension'] = 'tar.gz'
      chef_run.converge(described_recipe)
      expect(chef_run).to put_ark('prometheus').with(
        extension: 'tar.gz'
      )
    end

    context 'runit' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'runit'
          node.set['prometheus']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'includes runit::default recipe' do
        expect(chef_run).to include_recipe('runit::default')
      end

      it 'enables runit_service' do
        expect(chef_run).to enable_runit_service('prometheus')
      end
    end

    context 'bluepill' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'bluepill'
          node.set['prometheus']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'includes bluepill::default recipe' do
        expect(chef_run).to include_recipe('bluepill::default')
      end

      it 'renders a bluepill configuration file' do
        expect(chef_run).to render_file("#{chef_run.node['bluepill']['conf_dir']}/prometheus.pill")
      end
    end

    context 'init' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'init'
          node.set['prometheus']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders an init.d configuration file' do
        expect(chef_run).to render_file('/etc/init.d/prometheus')
      end
    end

    context 'systemd' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'systemd'
          node.set['prometheus']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders a systemd service file' do
        expect(chef_run).to render_file('/etc/systemd/system/prometheus.service')
      end
    end
    context 'upstart' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04', file_cache_path: '/var/chef/cache') do |node|
          node.set['prometheus']['init_style'] = 'upstart'
          node.set['prometheus']['install_method'] = 'binary'
        end.converge(described_recipe)
      end

      it 'renders an upstart job configuration file' do
        expect(chef_run).to render_file('/etc/init/prometheus.conf')
      end
    end
  end
end
