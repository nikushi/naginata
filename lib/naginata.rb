require "nagios_analyzer/section_decorator"

module Naginata

  require "naginata/command/external_command"
  require "naginata/configuration"
  require "naginata/configuration/filter"
  require "naginata/configuration/nagios_server"
  require "naginata/configuration/service"
  require "naginata/runner"
  require "naginata/status"
  require "naginata/ui"
  require "naginata/version"

  class NaginatafileNotFound < StandardError; end

  class << self
    def ui
      @ui ||= UI::Shell.new
    end
  end
end
