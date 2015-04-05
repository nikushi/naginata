require 'naginata/configuration'
require 'sshkit'
Naginata::Configuration.env.set(:sshkit_backend, ::SSHKit::Backend::Printer)
