require 'nagip/cli/base'
require 'nagip/command/external_command'
require 'nagip/configuration'
require 'nagip/runner'

module Nagip::CLI
  class Notification < Base

    desc 'notification [hostpattern ..]', 'Enable or disable host and service notifications'
    method_option :enable, aliases: "-e", desc: "Enable notification", type: :boolean, default: false
    method_option :disable, aliases: "-d", desc: "Disable notification", type: :boolean, default: false
    method_option :force, aliases: "-f", desc: "Run without prompting for confirmation", type: :boolean, default: false
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean, default: false
    def enable_or_disable(*patterns)
      if !options[:enable] and !options[:disable]
        help(:enable_or_disable)
        abort "Either --enable or --disable options is required"
      end
      if options[:enable] and options[:disable]
        help(:enable_or_disable)
        abort "Both --enable and --disable options can not be given"
      end

      if options[:all_hosts]
        ::Nagip::Configuration.env.add_filter(:host, :all)
      elsif patterns.empty?
        help(:enable_or_disable)
        abort "At least one hostpattern must be given or use --all-hosts option"
      else
        ::Nagip::Configuration.env.add_filter(:host, patterns)
      end
      if options[:services]
        ::Nagip::Configuration.env.add_filter(:service, options[:services])
      end

      command_file = ::Nagip::Configuration.env.fetch(:nagios_server_options)[:command_file]

      if !options[:force]
        puts "Following notifications will be #{options[:enable] ? 'enabled' : 'disabled'}"
        Nagip::Runner.run_locally do |nagios_server, services|
          services.group_by{ |s| s.hostname }.each do |hostname, svcs|
            puts hostname
            svcs.each do |service|
              puts  "  - #{service.description}"
            end
          end
        end
        abort unless yes?("Are you sure?")
      end

      Nagip::Runner.run do |backend, nagios_server, services|
        path = nagios_server.fetch(:command_file) || command_file

        services.each do |service|
          opts = {path: (nagios_server.fetch(:command_file) || command_file), host_name: service.hostname}
          opts.merge!(service_description: service.description) if service.description != :ping
          action = options[:enable] ? 'enable' : 'disable'
          host_or_svc = service.description == :ping ? 'host' : 'svc'
          command_arg = Nagip::Command::ExternalCommand.send("#{action}_#{host_or_svc}_notifications".to_sym, opts).split(/\s+/, 2)
          command = command_arg.shift.to_sym
          backend.execute command, command_arg
        end
      end
      puts "Done"
    end

  end
end
