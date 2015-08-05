### 0.1.6 - 2015/08/05

CLI:

* Support any Naginatafile location other than cwd
  * Add --naginatafile CLI option and NAGINATAFILE environment variable
  * Naginatafile can be located at ~/.naginata/Naginatafile or /etc/Naginatafile

Fixes:

* Remove the params examples of nagios_server dsl from the template

### 0.1.5 - 2015/06/09

CLI:

* Print version number
* Add naginata activecheck subcommand

Fixes:

* Run commands on login user if run_command_as is not set

### 0.1.4 - 2015/04/08

CLI:

* Add shorter aliases -N for --nagios option
* Add -w option wide output for hosts and services view

Fixes:

* Filter nagios servers before loading cached status file

### 0.1.3 - 2015/04/06

Fixes:

* Fix uninitialized constant Naginata (NameError)

### 0.1.2 - 2015/04/06

Enhancement:

* Add tests to evaluate command execution output and behavior
* List hosts and their services and status

### 0.1.1 - 2015/04/03

Enhancement:

* Introduce `naginata init`

Fixes:

* --dry-run was broken

### 0.1.0 - 2015/04/02

* First release
