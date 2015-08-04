require 'naginata/dsl'
require 'naginata/configuration'
require 'naginata/shared_helpers'

module Naginata
  class Loader
    #module_function

    class << self
      include Naginata::DSL
      include SharedHelpers

      def load_configuration
        # Load defaults.rb
        instance_eval File.read(File.join(File.dirname(__FILE__), 'defaults.rb'))
        # Load Naginatafile
        naginatafile_path = ::Naginata::Configuration.env.fetch(:naginatafile) || find_naginatafile
        if naginatafile_path.nil? or !File.file?(naginatafile_path)
          raise NaginatafileNotFound, 'Could not locate Naginatafile'
        else
          instance_eval File.read naginatafile_path
        end
      end

      def load_remote_objects(fetch_options = {})
        require 'naginata/cli/fetch'
        # Refresh cached status.dat
        CLI::Fetch.new(fetch_options).run

        nagios_servers = Configuration.env.filter(Configuration.env.nagios_servers)
        nagios_servers.each do |nagios_server|
          status = ::Naginata::Status.find(nagios_server.hostname)
          status.service_items.group_by{ |section| section.host_name }.each do |host, sections|
            services = sections.map { |s| s.service_description }
            Configuration.env.host(host, services: services, on: nagios_server.hostname)
          end
        end
      end

    end
  end
end

