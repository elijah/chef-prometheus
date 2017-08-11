require_relative '../../../kitchen/data/spec_helper'

describe 'alertmanager service' do
  describe service('alertmanager') do
    it { should be_running }
  end

  describe port(9093) do
    it { should be_listening.with('tcp') }
  end
end

describe 'alertmanger should be exposing metrics' do
  describe command("curl 'http://localhost:9093/#/alerts/'") do
    its(:stdout) { should include('<title>Alertmanager</title>') }
  end
end
