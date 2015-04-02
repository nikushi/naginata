module Naginata
  class Configuration
    class Service
      attr_reader :description, :hostname, :nagios

      # @param [String] description
      # @param [Hash] options
      # @option options [String] :host hostname monitored by nagios
      # @option options [String] :on nagios server name
      def initialize(description, options = {})
        ArgumentError if options[:host].nil?
        ArgumentError if options[:on].nil?
        @description = description
        @hostname = options[:host]
        @nagios = options[:on]
      end

      #def to_s
      #  @description
      #end

    end

    class Host < Service

      # @param [String] hostname
      # @param [Hash] options
      # @option options [String] :nagios nagios server name
      def initialize(hostname, options = {})
        super(:ping, options.merge(host: hostname))
      end

    end
  end
end
