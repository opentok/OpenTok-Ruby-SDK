# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "open_tok/version"

Gem::Specification.new do |s|
  s.name        = "opentok"
  s.version     = OpenTok::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stijn Mathysen", "Karmen Blake", "Song Zheng", "Patrick Quinn-Graham"]
  s.email       = ["stijn@skylight.be", "karmenblake@gmail.com", "song@tokbox.com", "pqg@tokbox.com"]
  s.homepage    = "https://github.com/opentok/Opentok-Ruby-SDK"
  s.summary     = %q{OpenTok gem}
  s.description = %q{OpenTok is an API from TokBox that enables websites to weave live group video communication into their online experience. With OpenTok you have the freedom and flexibility to create the most engaging web experience for your users. OpenTok is currently available as a JavaScript and ActionScript 3.0 library. This gem allows you to connect to the API from within Ruby (and Rails)}

  s.rubyforge_project = "opentok"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "addressable"
  s.add_dependency "json"
  s.add_dependency "rest-client"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
end
