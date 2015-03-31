require 'nagip/loader' # Load config
require 'nagip/cli/base'
require 'nagip/cli/status'

module Nagip::CLI
  class Boot < Base

    # Sub commands
    desc "status COMMANDS", "commands for host and service status"
    subcommand "status", ::Nagip::CLI::Status

    desc 'notification [hostpattern ..]', 'Control notification'
    method_option :enable, aliases: "-e", desc: "Enable notification", type: :boolean, default: false
    method_option :disable, aliases: "-d", desc: "Disable notification", type: :boolean, default: false
    method_option :force, aliases: "-f", desc: "Run without prompting for confirmation", type: :boolean, default: false
    method_option :services, aliases: "-s", desc: "Services to be enabled|disabled", type: :array
    method_option :all_hosts, aliases: "-a", desc: "Target all hosts", type: :boolean, default: false
    def notification(*patterns)
      require 'nagip/cli/notification'
      invoke ::Nagip::CLI::Notification, :enable_or_disable
    end

  end
end
