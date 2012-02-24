my_dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(File.join(my_dir, '..', 'lib'))
$LOAD_PATH.unshift(my_dir)
require 'simplecov'
SimpleCov.start

require 'rspec'
require 'config_library'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
end

COMMON_BATMAN_HASH = YAML.load_file(File.join(my_dir,'support','common_batman.yaml'))
