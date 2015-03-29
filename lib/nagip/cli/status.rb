require 'nagip/cli/base'
require 'nagip/configuration'
require 'nagip/status'

module Nagip::CLI
  class Status < Base
    #class_option :dry_run, aliases: "-n", type: :boolean
    #class_option :verbose, aliases: "-v", type: :boolean
    #class_option :debug, type: :boolean

    desc 'fetch', 'Download remote status.dat files into local as cache'
    def fetch
      Nagip::Runner.run do |backend, nagios_server, services|
        status_file = (nagios_server.fetch(:status_file) || ::Nagip::Configuration.env.fetch(:nagios_server_options)[:status_file])
        if !options[:dry_run]
          str = backend.capture(:cat, status_file)
          st = ::Nagip::Status.build(str, nagios_server.hostname)
          st.save
        else
          st = ::Nagip::Status.new
          st.hostname = nagios_server.hostname
        end
        puts "Saved into #{st.path}" if options[:verbose]
      end
    end

    desc 'show', 'Show nagios host and service status'
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean, default: false
    def show(*patterns)
      invoke :fetch

      if options[:all_hosts]
        ::Nagip::Configuration.env.add_filter(:host, :all)
      else
        ::Nagip::Configuration.env.add_filter(:host, patterns)
      end
      if options[:services]
        ::Nagip::Configuration.env.add_filter(:service, options[:services])
      end

      Nagip::Runner.run_locally do |nagios_server, _|
        st = ::Nagip::Status.find(nagios_server.hostname)
        st.status.service_items.group_by{|section| section.host_name}.each do |host_name, sections|
          puts host_name
          sections.each{|section| puts "  " + section.service_description }
          puts
        end
      end
    end
  end
end
 
