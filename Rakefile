require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f documentation"]
end
task :test => :spec
task :default => :spec

desc 'Open an irb session preloaded with the gem library'
task :console do
  require "bundler/setup"
  require "naginata"
  require "irb"
  ARGV.clear
  IRB.start
end
task :c => :console
