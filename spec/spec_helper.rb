$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/bootstrap'
require 'chef/knife/winrm_base'
require 'chef/knife/openstack_server_create'
require "securerandom"
require 'tmpdir'
require 'rbconfig'
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

def is_windows?
  if(ENV['OS'] != nil)
    ENV['OS'].downcase.include?("windows")
  end
end

def is_linux?
  RbConfig::CONFIG["arch"].include?("linux")
end

def create_dummy_validation_pem() 
  data_to_write = "../integration/config/validation.pem"
  if(is_windows?)
    if(!File.exist?('C:/chef/validation.pem'))
      FileUtils.mkpath 'C:/chef'
      create_file("C:/chef", "validation.pem", data_to_write)
    end
  end
  if(is_linux?)
    if(!File.exist?('/etc/chef/validation.pem'))
      # FIXME a dummy file needs to be present at '/etc/chef'
      FileUtils.mkpath '/etc/chef'
      create_file("/etc/chef", "validation.pem", data_to_write)
    end
  end
end

def create_file(file_dir, file_name, data_to_write_file_path)
  data_to_write = File.read(File.expand_path("#{data_to_write_file_path}", __FILE__))
  File.open("#{file_dir}/#{file_name}", 'w') {|f| f.write(data_to_write)}
  puts "Creating: #{file_dir}/#{file_name}" 
end