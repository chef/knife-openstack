# frozen_string_literal: true
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.

require "bundler"
require "bundler/setup"
require "bundler/gem_tasks"
require "chefstyle"
require "rubocop/rake_task"
require "rspec/core/rake_task"
require "github_changelog_generator/task"
require "knife-openstack/version"

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec]

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = Knife::OpenStack::VERSION
    config.issues = true
  end
rescue LoadError
  puts "github_changelog_generator is not available. gem install github_changelog_generator to generate changelogs"
end
