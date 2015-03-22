require 'nagip/dsl'

module Nagip
  class Loader
    #module_function

    class << self
      include Nagip::DSL

      def run
        instance_eval File.read(File.join(File.dirname(__FILE__), 'defaults.rb'))
        instance_eval File.read 'Nagipfile'
      end
    end
  end
end

Nagip::Loader.run
