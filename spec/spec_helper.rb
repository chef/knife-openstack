$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/openstack_server_create'
require "securerandom"
require 'knife-openstack/version'
require 'test/knife-utils/test_bed'

def find_instance_id(instance_name, file)
  file.lines.each do |line|
    if line.include?("#{instance_name}")
      return "#{line}".split(': ')[1].strip
    end
  end
end