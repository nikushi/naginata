require 'thor'
require 'naginata/configuration'
require 'naginata/loader'

module Naginata
  class CLI < Thor
    class_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    class_option :dry_run, aliases: "-n", type: :boolean
    class_option :verbose, aliases: "-v", type: :boolean
    class_option :debug, type: :boolean

    def initialize(args = [], opts = [], config = {})
      super(args, opts, config)

      Loader.load_configuration

      if options[:debug]
        ::Naginata::Configuration.env.set(:log_level, :debug)
      elsif options[:verbose]
        ::Naginata::Configuration.env.set(:log_level, :info)
      end

      # @Note This has a problem, in nap CLI::Base class is initialied multiple
      # time,  below add same filter every time. This should be fixed but not
      # critical.
      if options[:nagios]
        ::Naginata::Configuration.env.add_filter(:nagios_server, options[:nagios])
      end

      configure_backend

      Loader.load_remote_objects
    end

    desc 'notification [hostpattern ..]', 'Control notification'
    method_option :enable, aliases: "-e", desc: "Enable notification", type: :boolean, default: false
    method_option :disable, aliases: "-d", desc: "Disable notification", type: :boolean, default: false
    method_option :force, aliases: "-f", desc: "Run without prompting for confirmation", type: :boolean, default: false
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean, default: false
    def notification(*patterns)
      require 'naginata/cli/notification'
      CLI::Notification.new(options.merge(patterns: patterns)).run
    end

    desc 'fetch', 'Download remote status.dat and create cache on local'
    def fetch
      require 'naginata/cli/fetch'
      CLI::Fetch.new.run
    end

    no_tasks do

      def configure_backend
        if options[:dry_run]
          require 'sshkit/backends/printer'
          ::Naginata::Configuration.env.set(:sshkit_backend, SSHKit::Backend::Printer)
        end
        ::Naginata::Configuration.env.configure_backend
      end

    end

  end
end
 
