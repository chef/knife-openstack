# -*- encoding: utf-8 -*-
#
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "knife-openstack/version"

Gem::Specification.new do |s|
  s.name        = "knife-openstack"
  s.version     = Knife::OpenStack::VERSION
  s.version = "#{s.version}-alpha-#{ENV["TRAVIS_BUILD_NUMBER"]}" if ENV["TRAVIS"]
  s.authors     = ["JJ Asghar"]
  s.email       = ["jj@chef.io"]
  s.homepage    = "https://github.com/chef/knife-openstack"
  s.summary     = "A Chef knife plugin for OpenStack clouds."
  s.description = s.summary
  s.license     = "Apache-2.0"

  s.files         = %w{LICENSE} + Dir.glob("lib/**/*")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3"

  s.add_dependency "fog", ">= 1.23", "< 3.0"
  s.add_dependency "chef", ">= 13"
  s.add_dependency "knife-cloud", ">= 1.2.0", "< 3.0"

end
