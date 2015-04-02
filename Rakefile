require "bundler/gem_tasks"

desc 'Open an irb session preloaded with the gem library'
task :console do
  require "bundler/setup"
  require "naginata"
  require "irb"
  ARGV.clear
  IRB.start
end
task :c => :console
