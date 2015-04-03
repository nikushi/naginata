require 'naginata'
require 'naginata/cli/remote_abstract'
require 'naginata/command/external_command'
require 'naginata/configuration'
require 'naginata/runner'

module Naginata
  class CLI::Notification < CLI::RemoteAbstract

    def run
      if !@options[:enable] and !@options[:disable]
        abort "Either --enable or --disable options is required"
      end
      if @options[:enable] and @options[:disable]
        abort "Both --enable and --disable options can not be given"
      end

      if @options[:all_hosts]
        ::Naginata::Configuration.env.add_filter(:host, :all)
      elsif @options[:patterns].empty?
        abort "At least one hostpattern must be given or use --all-hosts option"
      else
        ::Naginata::Configuration.env.add_filter(:host, @options[:patterns])
      end
      if @options[:services]
        ::Naginata::Configuration.env.add_filter(:service, @options[:services])
      end

      command_file = ::Naginata::Configuration.env.fetch(:nagios_server_options)[:command_file]

      if !@options[:force]
        Naginata.ui.info "Following notifications will be #{@options[:enable] ? 'enabled' : 'disabled'}", true
        Naginata::Runner.run_locally do |nagios_server, services|
          services.group_by{ |s| s.hostname }.each do |hostname, svcs|
            puts hostname
            svcs.each do |service|
              Naginata.ui.info "  - #{service.description}", true
            end
          end
        end
        abort unless Naginata.ui.yes?("Are you sure? [y|N]")
      end

      Naginata::Runner.run do |backend, nagios_server, services|
        path = nagios_server.fetch(:command_file) || command_file

        services.each do |service|
          opts = {path: (nagios_server.fetch(:command_file) || command_file), host_name: service.hostname}
          opts.merge!(service_description: service.description) if service.description != :ping
          action = @options[:enable] ? 'enable' : 'disable'
          host_or_svc = service.description == :ping ? 'host' : 'svc'
          command_arg = Naginata::Command::ExternalCommand.send("#{action}_#{host_or_svc}_notifications".to_sym, opts).split(/\s+/, 2)
          command = command_arg.shift.to_sym
          backend.execute command, command_arg
        end
      end
      Naginata.ui.info "Done", true
    end

  end
end
