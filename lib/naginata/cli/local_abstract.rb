require 'naginata/cli/remote_abstract'

module Naginata
  class CLI::LocalAbstract < CLI::RemoteAbstract

    def configure_backend; end
    def load_remote_objects; end

  end
end

 
