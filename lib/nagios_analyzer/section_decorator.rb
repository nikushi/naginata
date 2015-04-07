require 'nagios_analyzer'

module NagiosAnalyzer
  class Section

    def decorate
      @decorator ||= SectionDecorator.new(self)
    end

  end
end

module NagiosAnalyzer
  class SectionDecorator

    attr_reader :object

    def initialize(section)
      @object = section
    end

    def current_state
      if object.current_state
        Status::STATES[object.current_state]
      end
    end

    def flags_short
      ret = []
      ret.push (object.active_checks_enabled == 1)  ? "AC": "ac"
      ret.push (object.notifications_enabled == 1)  ? "NT": "nt"
      ret.join(",")
    end

  end
end

