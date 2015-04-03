# Naginata

Naginata is multi nagios server control tool. If you have multiple nagios servers and want to control them from single workstation host by CLI over ssh connection, Naginata is good for you.

Naginata includes `naginata` command executable. `naginata` command can be done by just single command execution from workstation host.

* Enable/Disable notifications of hosts and services.
* Display current host and service status. (will be added)
* and more

If you already have nagios servers, it's easy to try out Naginata! It does not require to install ruby and Naginata on remote nagio servers.

## Requirements

Set up a workstation host which can connect to nagios servers over ssh connection. Currently supports only no passphrase remote login.

## Installation

Install naginata on workstation host.

    $ gem install naginata

Or if you use bundler, add this line to your application's Gemfile:

```ruby
gem 'naginata'
```

And then execute:

    $ bundle


## Configuration

Next, create a configuration file from the template. The below command creates _Naginatafile_ on the current working directory.

    $ naginata init

And then edit Naginatafile

```
# Define nagios servers
nagios_server 'foo@nagios1.example.com'
nagios_server 'bar@nagios2.example.com'
nagios_server 'baz@nagios3.example.com'

# Global nagios server options 
set :nagios_server_options, {
  command_file: '/usr/local/nagios/var/rw/nagios.cmd',
  status_file: '/usr/local/nagios/var/status.cmd',
  run_command_as: 'nagios',
}

# Global SSH options
set :ssh_options, {
  keys: %w(/home/nikushi/.ssh/id_rsa),
}
```

## Usage

### Notification

#### Enable(Disable) host and service notifications of server001

```
$ naginata notification server001 -[e|d]
```

#### Enable(Disable) host and specific service notifications of server001

```
$ naginata notification server001 -s cpu -[e|d] 
```

#### Enable(Disable) host and service notifications of all hosts

```
$ naginata notification -a -[e|d] 
```

#### Enable(Disable) specific service notifications of all hosts

```
$ naginata notification -a -s cpu -[e|d] 
```

### Display status (will be added)

#### Show server001's status

```
$ naginata status server001
```

#### Show all hosts' status

```
$ naginata status -a
```

#### Show all hosts' specific service status

```
$ naginata status -a -s cpu
```


### Global Options

#### Filter by nagios servers

You can filter target host and servers scope with `--nagios=server1,..` option.

```
$ naginata --nagios=nagios1.example.com,nagios2.example.com notification -e --all-hosts
```

#### Dry run mode

naginata command with `-n` or `--dry-run` runs as dry run mode.

#### Verbose output

naginata command with `-v`

#### Debug output

naginata command with `--debug`


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/naginata/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
