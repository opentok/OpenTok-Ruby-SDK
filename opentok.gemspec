# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "open_tok/version"

Gem::Specification.new do |s|
  s.name        = "opentok"
  s.version     = Opentok::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karmen Blake"]
  s.email       = ["karmenblake@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{OpenTok gem}
  s.description = %q{OpenTok is a free set of APIs from TokBox that enables websites to weave live group video communication into their online experience. With OpenTok you have the freedom and flexibility to create the most engaging web experience for your users. OpenTok is currently available as a JavaScript and ActionScript 3.0 library. This gem allows you to connect to the API from within Ruby (and Rails)}

  s.rubyforge_project = "opentok"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
