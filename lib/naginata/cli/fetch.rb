require 'naginata/cli/remote_abstract'
require 'naginata/configuration'
require 'naginata/status'
require 'naginata/runner'

module Naginata
  class CLI::Fetch < CLI::RemoteAbstract

    def run
      Naginata::Runner.run do |backend, nagios_server, services|
        status_file = (nagios_server.fetch(:status_file) || ::Naginata::Configuration.env.fetch(:nagios_server_options)[:status_file])
        if !@options[:dry_run]
          str = backend.capture(:cat, status_file)
          st = ::Naginata::Status.build(str, nagios_server.hostname)
          st.save
        else
          st = ::Naginata::Status.new
          st.hostname = nagios_server.hostname
        end
        puts "Saved into #{st.path}" if @options[:verbose]
      end

    end

    def load_remote_objects
    end

  end
end
 
