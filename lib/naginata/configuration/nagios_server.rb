require 'sshkit'

module Naginata
  class Configuration
    class NagiosServer < SSHKit::Host
      extend Forwardable
      def_delegators :properties, :fetch, :set

      def with(properties)
        properties.each { |key, value| add_property(key, value) }
        self
      end

      def properties
        @properties ||= Properties.new
      end

      def netssh_options
        @netssh_options ||= super.merge( fetch(:ssh_options) || {} )
      end

      def matches?(other)
        hostname == other.hostname
      end

      private

      def add_property(key, value)
        if respond_to?("#{key}=")
          send("#{key}=", value)
        else
          set(key, value)
        end
      end

      class Properties

        def initialize
          @properties = {}
        end

        def set(key, value)
          pval = @properties[key]
          if pval.is_a? Hash and value.is_a? Hash
            pval.merge!(value)
          elsif pval.is_a? Array and value.is_a? Array
            pval.concat value
          else
            @properties[key] = value
          end
        end

        def fetch(key)
          @properties[key]
        end

        def respond_to?(method, include_all=false)
          @properties.has_key?(method)
        end

        def keys
          @properties.keys
        end

        def method_missing(key, value=nil)
          if value
            set(lvalue(key), value)
          else
            fetch(key)
          end
        end

        private

        def lvalue(key)
          key.to_s.chomp('=').to_sym
        end

      end

    end
  end
end
