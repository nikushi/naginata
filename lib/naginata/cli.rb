require 'thor'
require 'naginata/configuration'
require 'naginata/loader'

module Naginata
  class CLI < Thor
    class_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    class_option :dry_run, aliases: "-n", type: :boolean
    class_option :verbose, aliases: "-v", type: :boolean
    class_option :debug, type: :boolean

    #def initialize(args = [], opts = [], config = {})
    #  super(args, opts, config)
    #end

    desc 'init', 'Init generates a default Nagipfile into current directory'
    def init
      require 'naginata/cli/init'
      CLI::Init.new(options).execute
    end

    desc 'notification [hostpattern ..]', 'Control notification'
    method_option :enable, aliases: "-e", desc: "Enable notification", type: :boolean, default: false
    method_option :disable, aliases: "-d", desc: "Disable notification", type: :boolean, default: false
    method_option :force, aliases: "-f", desc: "Run without prompting for confirmation", type: :boolean, default: false
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean, default: false
    def notification(*patterns)
      require 'naginata/cli/notification'
      CLI::Notification.new(options.merge(patterns: patterns)).execute
    end

    desc 'fetch', 'Download remote status.dat and create cache on local'
    def fetch
      require 'naginata/cli/fetch'
      CLI::Fetch.new(options).execute
    end

  end
end
 
