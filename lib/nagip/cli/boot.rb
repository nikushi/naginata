require 'nagip/loader' # Load config
require 'nagip/runner'
require 'nagip/command/external_command'
require 'nagip/cli/base'
require 'nagip/configuration'

module Nagip::CLI
  class Boot < Base


    desc 'notification [hostpattern ..]', 'control notification'
    method_option :enable, aliases: "-e", desc: "Enable notification", type: :boolean, default: false
    method_option :disable, aliases: "-d", desc: "Disable notification", type: :boolean, default: false
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean, default: false
    def notification(*patterns)
      if !options[:enable] and !options[:disable]
        abort "--enable or --disable options is required"
      end
      if options[:enable] and options[:disable]
        abort "Both --enable and --disable options can not be set"
      end
      if options[:all_hosts]
        ::Nagip::Configuration.env.add_filter(:host, :all)
      else
        ::Nagip::Configuration.env.add_filter(:host, patterns)
      end
      if options[:services]
        ::Nagip::Configuration.env.add_filter(:service, options[:services])
      end

      if options[:enable]
        method = :enable_svc_notifications
      elsif options[:disable]
        method = :disable_svc_notifications
      else
        abort "not supported"
      end

      command_file = ::Nagip::Configuration.env.fetch(:nagios_server_options)[:command_file]

      Nagip::Runner.run do |backend, nagios_server, services|
        services.each do |service|
          opts = {path: (nagios_server.fetch(:command_file) || command_file), host_name: service.hostname, service_description: service.description}
          command_arg = Nagip::Command::ExternalCommand.send(method, opts).split(/\s+/, 2)
          command = command_arg.shift.to_sym
          backend.execute command, command_arg
        end
      end
    end

  end
end
