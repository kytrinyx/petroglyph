# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "petroglyph/version"

Gem::Specification.new do |s|
  s.name        = "petroglyph"
  s.version     = Petroglyph::VERSION
  s.authors     = ["Katrina Owen"]
  s.email       = ["katrina.owen@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A simple, terse, and unsurprising ruby dsl to create json views.}
  s.description = %q{A simple, terse, and unsurprising ruby dsl to create json views.}

  s.rubyforge_project = "petroglyph"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "tilt"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "rack-test"
end
