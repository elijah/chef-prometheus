require 'spec_helper'

describe 'prometheus::source' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
      node.set['root_group'] = 'root'
    end.converge(described_recipe)
  end

  it 'includes build-essential' do
    expect(chef_run).to include_recipe('build-essential::default')
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
      owner: 'root',
      group: 'root',
      mode: '0755',
      recursive: true
    )
  end

  %w( curl git-core mercurial gzip sed ).each do |pkg|
    it 'installs #{pkg}' do
      expect(chef_run).to install_package(pkg)
    end
  end

  it 'checks out prometheus from github' do
    expect(chef_run).to checkout_git("#{Chef::Config[:file_cache_path]}/prometheus-0.11.1").with(
      repository: 'https://github.com/prometheus/prometheus.git',
      revision: '0.11.1'
    )
  end

  it 'compiles prometheus source' do
    expect(chef_run).to run_bash('compile_prometheus_source')
  end

  it 'notfies prometheus to restart' do
    resource = chef_run.bash('compile_prometheus_source')
    expect(resource).to notify('service[prometheus]').to(:restart)
  end

  it 'enables runit_service' do
    expect(chef_run).to enable_runit_service('prometheus')
  end

  it 'prometheus service does nothing' do
    expect(chef_run.service('prometheus')).to do_nothing
  end

end
