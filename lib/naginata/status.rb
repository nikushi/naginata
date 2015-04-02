require 'nagios_analyzer'
require 'forwardable'
require 'tempfile'

module Naginata
  class Status
    extend Forwardable
    def_delegators :@status, :service_items, :host_items, :items, :service_problems, :host_problems, :scopes
    attr_accessor :status, :hostname

    # Write status.dat into local disk
    #
    # @return [Naginata::Status] return self
    # @return [false] if @status is nil
    def save
      return false if status.nil?
      File.open(path, "w") do |f|
        f.sync = true
        Marshal.dump(status, f)
      end
      self
    end

    def purge_cache
      if File.exist?(path)
        FileUtils.rm path
      end
    end

    # Path of marshal dumped status file
    # 
    # @return [String] path of marshal dumped status file
    def path
      raise "@hostname must be set" if hostname.nil?
      @path ||= File.join(self.class.cache_dir, "#{hostname}.status.dat")
    end

    # Create a new instance from raw status.dat string
    #
    # @param [String] string raw status.dat text
    # @param [String] nagios_server_hostname hostname to identify status.data data
    # @return [Naginata::Status]
    def self.build(string, nagios_server_hostname)
      instance = new
      instance.hostname = nagios_server_hostname

      # @Note NagiosAnalizer::Status.new requires filename, so here
      # needs to write text data into tempfile.
      Tempfile.open(["naginata-#{nagios_server_hostname}", ".status.dat"]) do |temp|
        temp.sync = true
        temp.write string
        instance.status = ::NagiosAnalyzer::Status.new(temp.path, include_ok: true)
        temp.close!
      end
      instance
    end

    # Return a directory path for status.dat caching
    # 
    # @return [String] directory path for status.dat caching
    def self.cache_dir
      dir = (ENV['HOME'] && Dir.exist?(ENV['HOME'])) ? ENV['HOME'] : Dir.pwd
      dir = File.join(dir, '.naginata/cache/status')
      FileUtils.mkdir_p dir
      return dir
    end

    # Find a instance from cache by nagios server hostname
    #
    # @return [Naginata::Status]
    def self.find(nagios_server_hostname)
      instance = new
      instance.hostname = nagios_server_hostname
      if File.exist?(instance.path)
        File.open(instance.path) { |f| instance.status = Marshal.load(f) }
        return instance
      end
    end

  end
end
 
