require 'naginata/configuration'

module Naginata
  module DSL

    def nagios_server(name)
      Configuration.env.nagios_server(name)
    end

    def fetch(key, default=nil, &block)
      env.fetch(key, default, &block)
    end

    def env
      Configuration.env
    end

    def set(key, value)
      env.set(key, value)
    end

    def set_if_empty(key, value)
      env.set_if_empty(key, value)
    end

  end
end

