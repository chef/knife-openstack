# frozen_string_literal: true
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.

require 'bundler'
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'chefstyle'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'github_changelog_generator/task'
require 'knife-openstack/version'

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec]

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.future_release = Knife::OpenStack::VERSION
  config.max_issues = 0
  config.add_issues_wo_labels = false
  config.enhancement_labels = 'enhancement,Enhancement,New Feature,Feature'.split(',')
  config.bug_labels = 'bug,Bug,Improvement,Upstream Bug'.split(',')
  config.exclude_labels = 'duplicate,question,invalid,wontfix,no_changelog,Exclude From Changelog,Question,Discussion,Tech Cleanup'.split(',')
end
