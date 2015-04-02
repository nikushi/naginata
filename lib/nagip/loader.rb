require 'nagip/dsl'

module Nagip
  class Loader
    #module_function

    class << self
      include Nagip::DSL

      def load_configuration
        instance_eval File.read(File.join(File.dirname(__FILE__), 'defaults.rb'))
        instance_eval File.read 'Nagipfile'
      end

      def load_remote_objects
        require 'nagip/cli/fetch'
        # Refresh cached status.dat
        CLI::Fetch.new.run

        # Load status.dat
        #
        # @Note currently here reads all nagios servers' cache files. This
        # means that users can not reduce nagios servers by --nagios= CLI 
        # option. Below loop may be moved into initialization phase of CLI
        # class.
        Configuration.env.nagios_servers.each do |nagios_server|
          status = ::Nagip::Status.find(nagios_server.hostname)
          status.service_items.group_by{ |section| section.host_name }.each do |host, sections|
            services = sections.map { |s| s.service_description }
            Configuration.env.host(host, services: services, on: nagios_server.hostname)
          end
        end

      end

    end
  end
end

