require 'naginata/configuration'
require 'naginata/loader'

module Naginata
  class CLI::RemoteAbstract

    def initialize(options = {})
      @options = options
    end

    def execute
      set_custom_naginatafile
      load_configuration
      set_log_level
      set_nagios_filter
      configure_backend
      load_remote_objects
      run
    end

    def set_custom_naginatafile
      if custom_path = @options[:naginatafile] || ENV['NAGINATAFILE']
        custom_path = File.expand_path(custom_path)
        raise NaginatafileNotFound, "Could not locate Naginatafile" unless File.file?(custom_path)
        ::Naginata::Configuration.env.set(:naginatafile, custom_path)
      end
    end

    def set_log_level
      if @options[:debug]
        ::Naginata::Configuration.env.set(:log_level, :debug)
      elsif @options[:verbose]
        ::Naginata::Configuration.env.set(:log_level, :info)
      end
    end

    def set_nagios_filter
      if @options[:nagios]
        ::Naginata::Configuration.env.add_filter(:nagios_server, @options[:nagios])
      end
    end

    def load_configuration
      Loader.load_configuration
    end

    def configure_backend
      if @options[:dry_run]
        require 'sshkit/backends/printer'
        ::Naginata::Configuration.env.set(:sshkit_backend, SSHKit::Backend::Printer)
      end
      ::Naginata::Configuration.env.configure_backend
    end

    def load_remote_objects
      Loader.load_remote_objects(@options)
    end

    def run
      raise NotImplementedError, 'Called abstract method'
    end
  end
end


