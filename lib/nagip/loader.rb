require 'nagip/dsl'

module Nagip
  class Loader
    #module_function

    class << self
      include Nagip::DSL

      def run
        instance_eval File.read(File.join(File.dirname(__FILE__), 'defaults.rb'))
        instance_eval File.read 'Nagipfile'
        load_remote_objects
      end

      private

      def load_remote_objects
        require 'nagip/cli/status'
        require 'nagip/status'

        # Refresh cached status.dat
        CLI::Status.new.invoke(:fetch)

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

Nagip::Loader.run
