# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'naginata/version'

Gem::Specification.new do |spec|
  spec.name          = "naginata"
  spec.version       = Naginata::VERSION
  spec.authors       = ["Nobuhiro Nikushi"]
  spec.email         = ["deneb.ge@gmail.com"]

  spec.summary       = "Remote multi nagios server control tool"
  spec.description   = "Remote multi nagios server control tool over ssh connection"
  spec.homepage      = "https://github.com/nikushi/naginata"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sshkit', '~> 1.7'
  spec.add_dependency 'thor'
  spec.add_dependency 'nagios_analyzer', '~> 0.0.5'
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
end
