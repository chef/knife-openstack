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

def is_config_present 
  is_config_present = File.exist?(File.expand_path("../integration/config/environment.yml", __FILE__)) 
  if(!is_config_present)
    puts "\nSkipping the integration tests for knife openstack commands"
    puts "\nPlease make sure environment.yml is present and set with valid credentials."
    puts "\nPlease look for a sample file at spec/integration/config/environment.yml.sample"
    puts "\nPlease make sure openstack.pem is present and set with valid key pair content. This content should match for key pair name mentioned in environment.yml at attribute 'key_pair: key_pair_name'"
    puts "\nBy default openstack.pem contains dummy key pair content.\n"
  end
  is_config_present
end