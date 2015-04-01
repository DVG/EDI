# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'edi/version'

Gem::Specification.new do |spec|
  spec.name          = "edi"
  spec.version       = EDI::VERSION
  spec.authors       = ["DVG"]
  spec.email         = ["bradley.temple@gmail.com"]
  spec.summary       = %q{Chatbot Application Framework for Slack Chat Rooms}
  spec.homepage      = "https://github.com/DVG/edi.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-cucumber"
  spec.add_development_dependency "terminal-notifier-guard"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "childprocess"
  spec.add_dependency "httparty"
  spec.add_dependency "thor"
  spec.add_dependency "activesupport"
  spec.add_dependency "hooks"
  spec.add_dependency "twitter"
  spec.add_dependency "rufus-scheduler"
  spec.add_dependency "faye-websocket"
end
