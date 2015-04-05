$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'naginata'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file unless file =~ /fake_sshkit_backend\.rb$/
end

RSpec.configure do |config|
  config.include ::Spec::Helpers
  config.include ::Spec::Path

  config.before :each do
    reset!
    in_app_root
  end
end
