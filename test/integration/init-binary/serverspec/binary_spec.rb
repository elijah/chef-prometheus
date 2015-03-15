require_relative '../../../kitchen/data/spec_helper'

describe 'prometheus service' do
  describe command('/etc/init.d/prometheus status') do
    its(:stdout) { should match(/prometheus is running/) }
  end

  describe port(9090) do
    it { should be_listening }
  end
end
