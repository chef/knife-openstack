$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/openstack_server_create'
require "securerandom"
require 'tmpdir'
require 'fileutils'
require File.expand_path(File.dirname(__FILE__) +'/utils/knifeutils')
require File.expand_path(File.dirname(__FILE__) +'/utils/matchers')

def temp_dir
  @_temp_dir ||= Dir.mktmpdir
end

def find_instance_id(instance_name, file)
  file.lines.each do |line|
    if line.include?("#{instance_name}")
      return "#{line}".split(': ')[1].strip
    end
  end
end

def match_status(test_run_expect)
  if "#{test_run_expect}" == "should fail"
    should_not have_outcome :status => 0
  elsif "#{test_run_expect}" == "should succeed"
    should have_outcome :status => 0
  elsif "#{test_run_expect}" == "should return empty list"
    should have_outcome :status => 0
  else
    should have_outcome :status => 0
  end
end

def create_file(file_dir, file_name, data_to_write_file_path)
  data_to_write = File.read(File.expand_path("#{data_to_write_file_path}", __FILE__))
  File.open("#{file_dir}/#{file_name}", 'w') {|f| f.write(data_to_write)}
  puts "Creating: #{file_name}"
end