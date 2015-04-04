# Inspired by bundler's spec/support/helpers.rb
module Spec
  module Helpers

    attr_reader :out, :err, :exitstatus

    def reset!
      t = tmp
      abort "Could not run because `tmp` is emtpy" if t.nil? or t.to_s.strip.empty?
      Dir["#{t}/*"].each do |dir|
        FileUtils.rm_rf dir
      end
      FileUtils.mkdir_p tmp
      @out, @err, @exitstatus = nil, nil, nil
    end

    def in_app_root(&blk)
      Dir.chdir(app, &blk)
    end

    def lib
      File.expand_path('../../../lib', __FILE__)
    end

    def naginata(cmd, options = {})
      bin = File.expand_path('../../../bin/naginata', __FILE__)
      requires = []
      requires << File.expand_path('../fake_sshkit_backend.rb', __FILE__)
      requires_str = requires.map{|r| "-r#{r}"}.join(" ")
      args = options.map do |k, v|
        v == true ? " --#{k}" : " --#{k} #{v}" if v
      end.join

      cmd = "#{Gem.ruby} -I#{lib} #{requires_str} #{bin} #{cmd.to_s}#{args}"
      sys_exec cmd
    end

    def sys_exec(cmd)
      require 'open3'
      out_str, err_str, status = Open3.capture3(cmd.to_s)
      @out = out_str.strip
      @err = err_str.strip
      @exitstatus = status.exitstatus
    end


    def create_file(filename, content)
      path = app(filename)
      File.open(path.to_s, 'w') do |f|
        f.puts content
      end
    end

    def naginatafile(content)
      create_file('Naginatafile', content)
    end
  end
end

