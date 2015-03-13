require_relative '../../../kitchen/data/spec_helper'

describe 'prometheus service' do
  describe service('prometheus') do
    it { should be_running }
  end

  describe port(9090) do
    it { should be_listening }
  end
end
