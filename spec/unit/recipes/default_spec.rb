require 'spec_helper'

describe 'prometheus::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
      node.set['prometheus']['source']['version'] = '0.12.0'
    end.converge(described_recipe)
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
    resource = chef_run.template('/opt/prometheus/prometheus.conf')
    expect(chef_run).to render_file('/opt/prometheus/prometheus.conf').with_content(start_with('# Global default settings.'))
    expect(resource).to notify('service[prometheus]').to(:restart)
  end

  # Test for source.rb

  context 'source' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['prometheus']['source']['version'] = '0.12.0'
        node.set['prometheus']['install_method'] = 'source'
      end.converge(described_recipe)
    end

    it 'includes build-essential' do
      expect(chef_run).to include_recipe('build-essential::default')
    end

    %w( curl git-core mercurial gzip sed ).each do |pkg|
      it 'installs #{pkg}' do
        expect(chef_run).to install_package(pkg)
      end
    end

    it 'checks out prometheus from github' do
      expect(chef_run).to checkout_git("#{Chef::Config[:file_cache_path]}/prometheus-0.12.0").with(
      repository: 'https://github.com/prometheus/prometheus.git',
      revision: '0.12.0'
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
        ChefSpec::SoloRunner.new do |node|
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
        ChefSpec::SoloRunner.new do |node|
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
        ChefSpec::SoloRunner.new do |node|
          node.set['prometheus']['init_style'] = 'init'
        end.converge(described_recipe)
      end

      it 'renders an init.d configuration file' do
        expect(chef_run).to render_file('/etc/init.d/prometheus')
      end
    end
  end

  # Test for binary.rb

  context 'binary' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['prometheus']['source']['version'] = '0.12.0'
        node.set['prometheus']['install_method'] = 'binary'
      end.converge(described_recipe)
    end

    before do
      stub_command('test -d /opt/prometheus/prometheus').and_return(false)
    end

    it 'creates a remote file' do
      expect(chef_run).to create_remote_file_if_missing("#{Chef::Config['file_cache_path']}/prometheus-0.12.0.tar.bz2")
    end

    it 'extract prometheus' do
      expect(chef_run).to run_execute('extract prometheus')
    end

    context 'runit' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new do |node|
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
        ChefSpec::SoloRunner.new do |node|
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
        ChefSpec::SoloRunner.new do |node|
          node.set['prometheus']['init_style'] = 'init'
        end.converge(described_recipe)
      end

      it 'renders an init.d configuration file' do
        expect(chef_run).to render_file('/etc/init.d/prometheus')
      end
    end
  end
end
