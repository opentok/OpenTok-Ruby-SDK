# coding: utf-8
require File.expand_path("../lib/opentok/version.rb", __FILE__)

Gem::Specification.new do |spec|
  spec.name        = "opentok"
  spec.version     = OpenTok::VERSION
  spec.authors     = ["Stijn Mathysen", "Karmen Blake", "Song Zheng", "Patrick Quinn-Graham", "Ankur Oberoi"]
  spec.email       = ["stijn@skylight.be", "karmenblake@gmail.com", "song@tokbox.com", "pqg@tokbox.com", "ankur@tokbox.com"]
  spec.summary     = %q{Ruby gem for the OpenTok API}
  spec.description = %q{OpenTok is an API from TokBox that enables websites to weave live group video communication into their online experience. With OpenTok you have the freedom and flexibility to create the most engaging web experience for your users. This gem lets you generate sessions and tokens for OpenTok applications. It also includes support for working with OpenTok 2.0 archives. See <http://tokbox.com/opentok/platform> for more details.}
  # TODO: this homepage isn't set up just yet
  spec.homepage    = "https://opentok.github.io/opentok-ruby-sdk"
  spec.license     = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1.1"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "webmock", "~> 2.3.2"
  spec.add_development_dependency "vcr", "~> 2.8.0"
  spec.add_development_dependency "yard", "~> 0.9.11"
  # TODO: exclude this for compatibility with rbx
  # spec.add_development_dependency "debugger", "~> 1.6.6"

  spec.add_dependency "addressable", "~> 2.3" #  2.3.0 <= version < 3.0.0
  spec.add_dependency "httparty", "~> 0.15.5"
  spec.add_dependency "activesupport", ">= 2.0"
  spec.add_dependency "jwt", ">= 1.5.6"
end
