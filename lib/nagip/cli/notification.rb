require 'nagip'
require 'nagip/command/external_command'
require 'nagip/configuration'
require 'nagip/runner'

module Nagip
  class CLI::Notification

    def initialize(options)
      @options = options
    end

    def run
      if !@options[:enable] and !@options[:disable]
        abort "Either --enable or --disable options is required"
      end
      if @options[:enable] and @options[:disable]
        abort "Both --enable and --disable options can not be given"
      end

      if @options[:all_hosts]
        ::Nagip::Configuration.env.add_filter(:host, :all)
      elsif @options[:patterns].empty?
        abort "At least one hostpattern must be given or use --all-hosts option"
      else
        ::Nagip::Configuration.env.add_filter(:host, @options[:patterns])
      end
      if @options[:services]
        ::Nagip::Configuration.env.add_filter(:service, @options[:services])
      end

      command_file = ::Nagip::Configuration.env.fetch(:nagios_server_options)[:command_file]

      if !@options[:force]
        Nagip.ui.info "Following notifications will be #{@options[:enable] ? 'enabled' : 'disabled'}", true
        Nagip::Runner.run_locally do |nagios_server, services|
          services.group_by{ |s| s.hostname }.each do |hostname, svcs|
            puts hostname
            svcs.each do |service|
              Nagip.ui.info "  - #{service.description}", true
            end
          end
        end
        abort unless Nagip.ui.yes?("Are you sure? [y|N]")
      end

      Nagip::Runner.run do |backend, nagios_server, services|
        path = nagios_server.fetch(:command_file) || command_file

        services.each do |service|
          opts = {path: (nagios_server.fetch(:command_file) || command_file), host_name: service.hostname}
          opts.merge!(service_description: service.description) if service.description != :ping
          action = @options[:enable] ? 'enable' : 'disable'
          host_or_svc = service.description == :ping ? 'host' : 'svc'
          command_arg = Nagip::Command::ExternalCommand.send("#{action}_#{host_or_svc}_notifications".to_sym, opts).split(/\s+/, 2)
          command = command_arg.shift.to_sym
          backend.execute command, command_arg
        end
      end
      Nagip.ui.info "Done", true
    end

  end
end
