if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'naginata'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file unless file =~ /fake_sshkit_backend\.rb$/
end

RSpec.configure do |config|
  config.include ::Spec::Helpers
  config.include ::Spec::Path

  config.alias_it_should_behave_like_to :it_runs, 'runs:'

  original_wd = Dir.pwd
  original_home = ENV['HOME']

  config.before :each do
    reset!
    in_app_root
  end

  config.after :each do
    Dir.chdir(original_wd)
    # Reset ENV
    ENV['NAGINATAFILE'] = nil
    ENV['HOME'] = original_home
  end
end
