require_relative '../../../kitchen/data/spec_helper'

describe 'prometheus service' do
  describe command('/opt/chef/embedded/bin/bluepill status prometheus') do
    its(:stdout) { should match(/up/) }
  end

  describe port(9090) do
    it { should be_listening }
  end
end
