require 'naginata'

module Naginata
  class StatusDecorator

    attr_reader :object

    def initialize(status)
      @object = status
    end

    def hosts_table
      object.host_items.sort.map do |section|
        [object.nagios, section.host_name, section.decorate.current_state, section.decorate.flags_short, section.plugin_output]
      end
    end

    def services_table
      object.service_items.sort.map do |section|
        [object.nagios, section.host_name, section.service_description, section.decorate.current_state, section.decorate.flags_short, section.plugin_output]
      end
    end

  end
end

