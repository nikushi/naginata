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
        tell_me(msg, nil, newline) if level("info")
      end

      def warn(msg, newline = nil)
        tell_me(msg, :yellow, newline) if level("warn")
      end

      def error(msg, newline = nil)
        tell_me(msg, :red, newline) if level("error")
      end

      def debug(msg, newline = nil)
        tell_me(msg, nil, newline) if level("debug")
      end

      def level(name = nil)
        name ? LEVELS.index(name) <= LEVELS.index(@level) : @level
      end

      def yes?(msg)
        @shell.yes?(msg)
      end

      private

      def tell_me(msg, color = nil, newline = nil)
        if newline.nil?
          @shell.say(msg, color)
        else
          @shell.say(msg, color, newline)
        end
      end

    end
  end
end
