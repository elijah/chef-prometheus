require_relative '../../../kitchen/data/spec_helper'

describe 'prometheus service' do
  describe command('/etc/init.d/prometheus status') do
    its(:stdout) { should match(/prometheus is running/) }
  end

  describe port(9090) do
    it { should be_listening }
  end

  describe 'prometheus should be exposing metrics' do
    describe command("curl 'http://localhost:9090/metrics'") do
      its(:stdout) { should match(/prometheus_notifications_queue_capacity 100/) }
    end
  end
end
