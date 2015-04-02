require 'thor/base'

module Naginata
  module UI
    class Shell
      LEVELS = %w(error warn info debug)

      def initialize
        @shell = Thor::Base.shell.new
        @level = ENV['DEBUG'] ? "debug" : "info"
      end

      def info(msg, newline = nil)
        @shell.say(msg, nil, newline) if level("info")
      end

      def warn(msg, newline = nil)
        @shell.say(msg, :yellow, newline) if level("warn")
      end

      def error(msg, newline = nil)
        @shell.say(msg, :red, newline) if level("error")
      end

      def debug(msg, newline = nil)
        @shell.say(msg, nil, newline) if level("debug")
      end

      def level(name = nil)
        name ? LEVELS.index(name) <= LEVELS.index(@level) : @level
      end

      def yes?(msg)
        @shell.yes?(msg)
      end

    end
  end
end
