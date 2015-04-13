require 'naginata'
require 'naginata/cli/remote_abstract'
require 'naginata/command/external_command'
require 'naginata/configuration'
require 'naginata/runner'

module Naginata
  class CLI::Downtime < CLI::RemoteAbstract

    def run
      if !@options[:schedule] and !@options[:cancel] and !@options[:list]
        Naginata.ui.error "Set a option from -S, -C or -l at least"
        exit(1)
      end
      if [@options[:schedule], @options[:cancel], @options[:list]].count(true) > 1
        Naginata.ui.error "You tried to set two or more options from -S, -C and -l, but it can't at one time"
        exit(1)
      end
      if @options[:schedule] and !@options[:end]
        Naginata.ui.error "--end option is required when scheduling downtimes"
        exit(1)
      end

      if @options[:list]
        list_hostdowntime
        Naginata.ui.info("")
        list_servicedowntime
        return
      end

      if @options[:cancel]
        Naginata.ui.error("Sorry but downtime cancelation is not implemeted yet.")
        exit(1)
      end

      # schedule
      require 'time'
      begin
        @options[:start] = Time.parse(@options[:start])
        @options[:end]   = Time.parse(@options[:end])
      rescue
        Naginata.ui.error "Start or end time can not be parsed"
        exit(1)
      end

      if @options[:start] >= @options[:end]
        Naginata.ui.error "Start or end time is not valid"
        exit(1)
      end
      schedule
    end

    private

    def schedule
      if @options[:all_hosts]
        ::Naginata::Configuration.env.add_filter(:host, :all)
      elsif @options[:patterns].empty?
        abort "At least one hostpattern must be given or use --all-hosts option"
      else
        ::Naginata::Configuration.env.add_filter(:host, @options[:patterns])
      end
      if @options[:services]
        ::Naginata::Configuration.env.add_filter(:service, @options[:services])
      end

      if !@options[:force]
        Naginata.ui.info "Author:  #{@options[:author]}"
        Naginata.ui.info "Comment: #{@options[:comment]}"
        Naginata.ui.info "Start:   #{@options[:start]}"
        Naginata.ui.info "End:     #{@options[:end]}"
        Naginata.ui.info ""
        Naginata.ui.info "Following downtimes will be scheduled"
        Naginata::Runner.run_locally do |nagios_server, services|
          services.group_by{ |s| s.hostname }.each do |hostname, svcs|
            Naginata.ui.info hostname
            svcs.each do |service|
              Naginata.ui.info "  - #{service.description}"
            end
          end
        end
        abort unless Naginata.ui.yes?("Are you sure? [y|N]")
      end

      Naginata::Runner.run do |backend, nagios_server, services|
        path = nagios_server.fetch(:command_file) || default_command_file

        services.each do |service|
          opts = {
            path: path,
            host_name: service.hostname,
            start_time: @options[:start].to_i,
            end_time: @options[:end].to_i,
            fixed: 1,
            author: @options[:author],
            comment: @options[:comment],
          }
          opts.merge!(service_description: service.description) if service.description != :ping
          action = 'schedule'
          host_or_svc = service.description == :ping ? 'host' : 'svc'
          command_arg = Naginata::Command::ExternalCommand.send("#{action}_#{host_or_svc}_downtime".to_sym, opts).split(/\s+/, 2)
          command = command_arg.shift.to_sym
          backend.execute command, command_arg
        end
      end
      Naginata.ui.info "Done"
    end

    def list_hostdowntime
      Naginata.ui.info("#")
      Naginata.ui.info("# host downtimes")
      Naginata.ui.info("#")
      table = []
      table << %w(NAGIOS HOST START END AUTHOR COMMENT)
      Naginata::Runner.run_locally do |nagios_server, services|
        targets = services.map{ |s| s.hostname }.uniq
        status = Status.find(nagios_server.hostname)
        status.scopes << lambda { |s|
          targets.any? {|host| s.include?("host_name=#{host}") }
        }
        table.concat(status.decorate.hostdowntime_table)
      end
      Naginata.ui.print_table(table, truncate: !@options[:wide])
    end

    def list_servicedowntime
      Naginata.ui.info("#")
      Naginata.ui.info("# service downtimes")
      Naginata.ui.info("#")
      table = []
      table << %w(NAGIOS HOST SERVICE START END AUTHOR COMMENT)
      Naginata::Runner.run_locally do |nagios_server, services|
        targets = services.map{ |s| s.hostname }.uniq
        target_services = services.reject{|s| s.description == :ping}.map{|s| s.description }.uniq
        status = Status.find(nagios_server.hostname)
        status.scopes << lambda { |s|
          targets.any? {|host| s.include?("host_name=#{host}") }
        }
        status.scopes << lambda { |s|
          target_services.any? {|desc| s.include?("service_description=#{desc}") }
        }
        table.concat(status.decorate.servicedowntime_table)
      end
      Naginata.ui.print_table(table, truncate: !@options[:wide])
    end

    def default_command_file
      ::Naginata::Configuration.env.fetch(:nagios_server_options)[:command_file]
    end

  end
end


