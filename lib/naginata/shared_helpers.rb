module Naginata
  module SharedHelpers
 
    def find_naginatafile
      file = %w(
        Naginatafile
        ~/.naginata/Naginatafile
        /etc/naginata/Naginatafile
      ).map{ |path| File.expand_path(path) }.find { |path| File.file?(path) }
      raise NaginatafileNotFound, "Could not locate Gemfile" unless file
      return file
    end

  end
end

