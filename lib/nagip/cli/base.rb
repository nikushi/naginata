require 'thor'
require 'nagip/configuration'

module Nagip::CLI
  class Base < Thor
    class_option :nagios, desc: "Filter hosts by nagios server names", type: :array
    class_option :dry_run, aliases: "-n", type: :boolean
    class_option :verbose, aliases: "-v", type: :boolean
    class_option :debug, type: :boolean

    def initialize(args = [], opts = [], config = {})
      super(args, opts, config)

      if options[:debug]
        ::Nagip::Configuration.env.set(:log_level, :debug)
      elsif options[:verbose]
        ::Nagip::Configuration.env.set(:log_level, :info)
      end

      if options[:nagios]
        ::Nagip::Configuration.env.add_filter(:nagios_server, options[:nagios])
      end

      configure_backend
    end

    no_tasks do

      def configure_backend
        if options[:dry_run]
          require 'sshkit/backends/printer'
          ::Nagip::Configuration.env.set(:sshkit_backend, SSHKit::Backend::Printer)
        end
        ::Nagip::Configuration.env.configure_backend
      end

    end

  end
end
 
