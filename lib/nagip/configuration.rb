require_relative 'configuration/filter'
require_relative 'configuration/nagios_server'
require_relative 'configuration/service'

module Nagip
  class Configuration

    def initialize(config = nil)
      @config ||= config
    end

    def self.env
      @env ||= new
    end

    def set(key, value)
      config[key] = value
    end

    def set_if_empty(key, value)
      config[key] = value unless config.has_key? key
    end

    def fetch(key, default=nil, &block)
      if block_given?
        config.fetch(key, &block)
      else
        config.fetch(key, default)
      end
    end

    def keys
      config.keys
    end

    # @ToDo second argment for server specific options
    def nagios_server(name)
      nagios_servers << NagiosServer.new(name)
    end

    def host(host, options = {})
      ArgumentError "on: is required option" unless options[:on]
      nagios = options[:on]
      services << Host.new(host, on: nagios)
      Array(options[:services]).each { |s| services << Service.new(s, host: host, on: nagios) }
    end

    def timestamp
      @timestamp ||= Time.now.utc
    end

    def add_filter(type, values)
      filters << Filter.new(type, values)
    end

    def filter list
      filters.reduce(list) { |l,f| f.filter l }
    end

    def filter_service list
      filters.reduce(list) { |l,f| f.filter_service l }
    end

    def nagios_servers
      @nagios_servers ||= []
    end

    def services
      @services ||= []
    end

    def backend
      SSHKit
    end

    def configure_backend
      backend.configure do |sshkit|
        sshkit.format           = fetch(:format)
        sshkit.output_verbosity = fetch(:log_level)
        sshkit.backend          = fetch(:sshkit_backend, SSHKit::Backend::Netssh)
        sshkit.backend.configure do |backend|
          backend.pty                = fetch(:pty)
          backend.ssh_options        = (backend.ssh_options || {}).merge(fetch(:ssh_options,{}))
        end
      end
    end


    private

    def filters
      @filters ||= []
    end

    def config
      @config ||= Hash.new
    end

  end
end
