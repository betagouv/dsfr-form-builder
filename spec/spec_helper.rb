RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
     expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true
end

require 'uri' # necessary on github actions
require 'action_view'
require 'active_support'
require 'active_model'
require 'nokogiri'

Dir[File.expand_path('{../lib/**/*.rb,support/**/*.rb}', __dir__)].sort.each { |f| require f }
