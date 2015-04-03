require 'naginata/cli/local_abstract'

module Naginata
  class CLI::Init < CLI::LocalAbstract
    def run
      if File.exist?("Naginatafile")
        Naginata.ui.error "Naginatafile already exists at #{Dir.pwd}/Naginatafile"
        exit 1
      end
      Naginata.ui.info "Writing new Naginatafile to #{Dir.pwd}/Naginatafile", true
      FileUtils.cp(File.expand_path('../../templates/Naginatafile', __FILE__), 'Naginatafile')
    end

    def load_configuration
      # Skip loading configuration because Nagipfile does not exist yet.
    end
  end
end
