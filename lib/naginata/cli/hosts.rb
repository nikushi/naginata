require 'naginata'
require 'naginata/cli/remote_abstract'
require 'naginata/configuration'
require 'naginata/status'
require 'naginata/runner'

module Naginata
  class CLI::Hosts < CLI::RemoteAbstract

    def run
      if @options[:all_hosts]
        ::Naginata::Configuration.env.add_filter(:host, :all)
      else
        ::Naginata::Configuration.env.add_filter(:host, @options[:patterns])
      end

      table = []
      table << %w(NAGIOS HOST STATUS FLAGS OUTPUT)
      Naginata::Runner.run_locally do |nagios_server, services|
        targets = services.map{ |s| s.hostname }.uniq
        status = Status.find(nagios_server.hostname)
        status.scopes << lambda { |s|
          targets.any? {|host| s.include?("host_name=#{host}") }
        }
        table.concat(status.decorate.hosts_table)
      end
      Naginata.ui.print_table(table, truncate: !@options[:wide])
    end

  end
end

