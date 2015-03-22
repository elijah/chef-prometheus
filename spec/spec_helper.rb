require 'chefspec'
require 'chefspec/berkshelf'
require_relative 'support/matchers'

RSpec.configure do |config|
  # No WARN messages during testing
  config.log_level = :error
end

ChefSpec::Coverage.start!
