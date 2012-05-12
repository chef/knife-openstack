# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "knife-openstack/version"

Gem::Specification.new do |s|
  s.name        = "knife-openstack"
  s.version     = Knife::OpenStack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.authors     = ["Seth Chisamore", "Matt Ray"]
  s.email       = ["schisamo@opscode.com", "matt@opscode.com"]
  s.homepage    = "https://github.com/opscode/knife-openstack"
  s.summary     = %q{OpenStack Compute Support for Chef's Knife Command}
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "fog", "~> 1.3.1"
  s.add_dependency "chef", "~> 0.10"
end
