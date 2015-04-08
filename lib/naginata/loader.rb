require 'naginata/dsl'

module Naginata
  class Loader
    #module_function

    class << self
      include Naginata::DSL

      def load_configuration
        instance_eval File.read(File.join(File.dirname(__FILE__), 'defaults.rb'))
        naginatafile_path = find_naginatafile
        instance_eval File.read naginatafile_path
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

      private

      def find_naginatafile
        naginatafile_path = File.expand_path('Naginatafile')
        if File.file?(naginatafile_path)
          return naginatafile_path
        else
          raise NaginatafileNotFound, 'Could not locate Naginatafile'
        end
      end

    end
  end
end

