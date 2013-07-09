$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/bootstrap'
require 'chef/knife/openstack_helpers'
require 'fog'
require 'chef/knife/winrm_base'
require 'chef/knife/bootstrap_windows_winrm'
require 'chef/knife/openstack_server_create'
require 'chef/knife/openstack_server_delete'
require 'chef/knife/bootstrap_windows_ssh'
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

def get_gem_file_name
  "knife-openstack-" + Knife::OpenStack::VERSION + ".gem"
end

def delete_instance_cmd(stdout)
  "knife openstack server delete " + find_instance_id("Instance ID:", stdout) +
  append_openstack_creds(is_list_cmd = true) + " --yes"
end

def create_node_name(name)
  @name_node  = (name == "linux") ? "ostsp-linux-#{SecureRandom.hex(4)}" :  "ostsp-win-#{SecureRandom.hex(4)}"
end


def init_openstack_test
  init_test
  begin
    data_to_write = File.read(File.expand_path("../integration/config/openstack.pem", __FILE__))
    File.open("#{temp_dir}/openstack.pem", 'w') {|f| f.write(data_to_write)}
  rescue
    puts "Error while creating file - openstack.pem"
  end

  begin
    data_to_write = File.read(File.expand_path("../integration/config/incorrect_openstack.pem", __FILE__))
    File.open("#{temp_dir}/incorrect_openstack.pem", 'w') {|f| f.write(data_to_write)}
  rescue
    puts "Error while creating file - incorrect_openstack.pem"
  end
end
