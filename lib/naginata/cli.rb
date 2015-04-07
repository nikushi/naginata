require 'thor'
require 'naginata/configuration'
require 'naginata/loader'

module Naginata
  class CLI < Thor
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
    method_option :enable, aliases: "-e", desc: "Enable notification", type: :boolean
    method_option :disable, aliases: "-d", desc: "Disable notification", type: :boolean
    method_option :dry_run, aliases: "-n", type: :boolean
    method_option :force, aliases: "-f", desc: "Run without prompting for confirmation", type: :boolean
    method_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean
    def notification(*patterns)
      if patterns.empty? and options.empty?
        help(:notification)
        exit(1)
      end
      require 'naginata/cli/notification'
      CLI::Notification.new(options.merge(patterns: patterns)).execute
    end

    method_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    desc 'fetch', 'Download remote status.dat and create cache on local'
    def fetch
      require 'naginata/cli/fetch'
      CLI::Fetch.new(options).execute
    end

    desc 'hosts [hostpattern ..]', 'View host status'
    method_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean
    method_option :wide, aliases: "-w", desc: "Wide output", type: :boolean
    def hosts(*patterns)
      if patterns.empty? and !options[:all_hosts]
        help(:hosts)
        exit(1)
      end
      require 'naginata/cli/hosts'
      CLI::Hosts.new(options.merge(patterns: patterns)).execute
    end

    desc 'services [hostpattern ..]', 'View service status'
    method_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    method_option :services, aliases: "-s", desc: "Filter by service description", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean
    method_option :wide, aliases: "-w", desc: "Wide output", type: :boolean
    def services(*patterns)
      if patterns.empty? and !options[:all_hosts]
        help(:services)
        exit(1)
      end
      require 'naginata/cli/services'
      CLI::Services.new(options.merge(patterns: patterns)).execute
    end
  end
end
 
