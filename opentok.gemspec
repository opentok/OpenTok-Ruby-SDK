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
  s.description = %q{OpenTok gem}

  s.rubyforge_project = "opentok"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
