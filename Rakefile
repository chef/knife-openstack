#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright 2013-2019 Chef Software, Inc.

require "bundler/setup"
require "bundler/gem_tasks"
begin
  require "chefstyle"
  require "rubocop/rake_task"
  desc "Run Chefstyle tests"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle gem is not installed. bundle install first to make sure all dependencies are installed."
end

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

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

task default: %i{spec style}
