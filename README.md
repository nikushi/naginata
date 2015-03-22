# Nagip

//Remote multi nagios server control tool. 
Nagip is multi nagios server control tool. It executes nagis external commands or read status file on remote nagios servers from single workstation host over ssh connection.

Nagip includes `nagip` command executable. `nagip` command can be used to:

* Display current host and service status. (will be added)
* Enable/Disable notifications of hosts and services.
* Add/Delete hosts/services downtime. (will be added)
* and more

Trying to nagip is really easy for you. You don't need to install ruby and nagip into nagios servers, just setup a workstation host which can login to nagios server over ssh.

## Requirements

Set up a workstation host which can connect to nagios servers over ssh connection. Currently nagip supports only no passphrase remote login.

## Installation

Install nagip on workstation host.

Add this line to your application's Gemfile:

```ruby
gem 'nagip'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nagip

## Configuration

Nagipfile

```
# Define nagios servers
nagios 'foo@nagios1.example.com'
nagios 'bar@nagios2.example.com'
nagios 'baz@nagios3.example.com'

# Define service objects within each nagios server manually like follows.
# This DSL may be removed.
host 'myrouter01', services: ['cpu', 'memory'], on: 'nagios1'
host 'myrouter02', services: ['cpu', 'memory'], on: 'nagios1'
host 'myrouter03', services: ['cpu', 'memory'], on: 'nagios1'
host 'web01', services: ['cpu', 'loadavg'], on: 'nagios2'
host 'db01', services: ['cpu', 'loadavg'], on: 'nagios2'
host 'memcached01', services: ['cpu', 'diskusage'], on: 'nagios2'

# nagios server global options 
set :nagios_server_options, {
  command_file: '/usr/local/nagios/var/rw/nagios.cmd',
  status_file: '/usr/local/nagios/var/status.cmd',
  run_command_as: 'nagios',
}

# Global options
set :ssh_options, {
  keys: %w(/home/nikushi/.ssh/id_rsa),
}
```

## Usage


### Display status (will be added)

#### Show server001's status

```
$ nagip status server001
```

#### Show all hosts' status

```
$ nagip status -a
```

#### Show all hosts' specific service status

```
$ nagip status -a -s cpu
```

### Notification

#### Enable(Disable) host and service notifications of server001

```
$ nagip notification server001 -[e|d]
```

#### Enable(Disable) host and specific service notifications of server001

```
$ nagip notification server001 -s cpu -[e|d] 
```

#### Enable(Disable) host and service notifications of all hosts

```
$ nagip notification -a -[e|d] 
```

#### Enable(Disable) specific service notifications of all hosts

```
$ nagip notification -a -s cpu -[e|d] 
```


### Global Options

#### Filter by nagios servers

You can filter target host and servers scope with `--nagios=server1,..` option.

```
$ nagip --nagios=nagios1.example.com,nagios2.example.com notification -e --all-hosts
```

#### Dry run mode

nagip command with `-n` or `--dry-run` runs as dry run mode.

#### Verbose output

nagip command with `-v`

#### Debug output

nagip command with `--debug`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/nagip/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
