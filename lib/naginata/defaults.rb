set_if_empty :format, :pretty
set_if_empty :log_level, :warn
set_if_empty :pty, false

set_if_empty :nagios_server_options, {
  command_file: '/usr/local/nagios/var/rw/nagios.cmd', 
   status_file: '/usr/local/nagios/var/status.cmd', 
}
