#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright 2013-2018 Chef Software, Inc.

require "bundler/setup"
require "bundler/gem_tasks"
require "chefstyle"
require "rubocop/rake_task"
require "rspec/core/rake_task"

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec)

task default: [:rubocop, :spec]

begin
  require "yard"
  YARD::Rake::YardocTask.new(:docs)
rescue LoadError
  puts "yard is not available. bundle install first to make sure all dependencies are installed."
end

task :console do
  require "irb"
  require "irb/completion"
  ARGV.clear
  IRB.start
end
