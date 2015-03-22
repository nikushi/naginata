require 'nagip/configuration'
require 'nagip/configuration/service'

module Nagip
  class Configuration
    class Filter
      def initialize type, values = nil
        raise "Invalid filter type #{type}" unless [:nagios_server, :host, :service].include? type
        av = Array(values).dup
        @mode = case
                when av.include?(:all) then :all
                else type
                end
        @rex = case @mode
          when :all
            nil # this creates a filter matching any string
          when :nagios_server, :host
            av.map!{|v| (v.is_a?(String) && v =~ /^(?<name>[-A-Za-z0-9.]+)(,\g<name>)*$/) ? v.split(',') : v }
            av.flatten!
            av.map! do |v|
              case v
              when Regexp then v
              else
                vs = v.to_s
                vs =~ /^[-A-Za-z0-9.]+$/ ? vs : Regexp.new(vs)
              end
            end
            Regexp.union av
          when :service
            av.map!{|v| v.is_a?(String) ? v.split(',') : v }
            av.flatten!
            av.map! do |v|
              case v
              when Regexp then v
              else
                vs = v.to_s
                Regexp.new(vs)
              end
            end
            Regexp.union av
          else
            raise "unprocessable type"
          end
      end

      def filter nagios_servers
        a = Array(nagios_servers)
        case @mode
        when :all
          a
        when :nagios_server
          a.select { |ns| @rex.match ns.to_s }
        else
          a
        end
      end

      def filter_service services
        a = Array(services)
        case @mode
        when :all
          a
        when :nagios_server
          a.select { |s| @rex.match s.nagios }
        when :host
          a.select { |s| @rex.match s.hostname }
        when :service
          # Ignore host monitors
          a.reject { |s| s.description == :ping }
           .select { |s| @rex.match s.description }
        else
          a
        end
      end

    end
  end
end
