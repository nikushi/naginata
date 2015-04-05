require 'naginata'
require 'naginata/cli/remote_abstract'
require 'naginata/configuration'
require 'naginata/status'
require 'naginata/runner'

module Naginata
  class CLI::Services < CLI::RemoteAbstract

     def run
      if @options[:all_hosts]
        ::Naginata::Configuration.env.add_filter(:host, :all)
      else
        ::Naginata::Configuration.env.add_filter(:host, @options[:patterns])
      end
      if @options[:services]
        ::Naginata::Configuration.env.add_filter(:service, @options[:services])
      end

      table = []
      table << %w(NAGIOS HOST SERVICE STATUS FLAGS OUTPUT)
      Naginata::Runner.run_locally do |nagios_server, services|
        target_hosts = services.map{|s| s.hostname }.uniq
        target_services = services.reject{|s| s.description == :ping}.map{|s| s.description }.uniq
        status = Status.find(nagios_server.hostname)
        status.scopes << lambda { |s|
          target_hosts.any? {|host| s.include?("host_name=#{host}") }
        }
        status.scopes << lambda { |s|
          target_services.any? {|desc| s.include?("service_description=#{desc}") }
        }
        table.concat(status.decorate.services_table)
      end
      Naginata.ui.print_table table
    end

  end
end

