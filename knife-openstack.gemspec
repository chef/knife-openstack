# -*- encoding: utf-8 -*-
# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'knife-openstack/version'

Gem::Specification.new do |s|
  s.name        = 'knife-openstack'
  s.version     = Knife::OpenStack::VERSION
  s.version = "#{s.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.authors     = ['JJ Asghar']
  s.email       = ['jj@chef.io']
  s.homepage    = 'https://github.com/chef/knife-openstack'
  s.summary     = 'A Chef knife plugin for OpenStack clouds.'
  s.description = 'A Chef knife plugin for OpenStack clouds.'
  s.license     = 'Apache-2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.2.2'

  s.add_dependency 'fog', '~> 1.23'
  s.add_dependency 'chef', '>= 12'
  s.add_dependency 'knife-cloud', '~> 1.2.0'
end
