require 'nagip/configuration'
require 'nagip/status'
require 'nagip/runner'

module Nagip
  class CLI::Fetch

    def initialize(options = {})
      @options = options
    end

    def run
      Nagip::Runner.run do |backend, nagios_server, services|
        status_file = (nagios_server.fetch(:status_file) || ::Nagip::Configuration.env.fetch(:nagios_server_options)[:status_file])
        if !@options[:dry_run]
          str = backend.capture(:cat, status_file)
          st = ::Nagip::Status.build(str, nagios_server.hostname)
          st.save
        else
          st = ::Nagip::Status.new
          st.hostname = nagios_server.hostname
        end
        puts "Saved into #{st.path}" if @options[:verbose]
      end

    end
  end
end
 
