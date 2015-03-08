require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  # No WARN messages during testing
  config.log_level = :error
end

ChefSpec::Coverage.start!
