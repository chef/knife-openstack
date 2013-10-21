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
require 'resource_spec_helper'

def find_instance_id(instance_name, file)
  file.lines.each do |line|
    if line.include?("#{instance_name}")
      return "#{line}".split(': ')[1].strip
    end
  end
end

def is_config_present
  unset_env_var = []
  is_config = true
  %w(OPENSTACK_USERNAME OPENSTACK_PASSWORD OPENSTACK_AUTH_URL OPENSTACK_TENANT OS_SSH_USER OPENSTACK_KEY_PAIR OS_WINDOWS_SSH_USER OS_WINDOWS_SSH_PASSWORD OS_WINRM_USER OS_WINRM_PASSWORD OS_LINUX_IMAGE OS_LINUX_FLAVOR OS_INVALID_FLAVOR OS_WINDOWS_FLAVOR OS_WINDOWS_IMAGE OS_WINDOWS_SSH_IMAGE).each do |os_env_var|
      ENV[os_env_var] = "60" if ( os_env_var == "OS_INVALID_FLAVOR" && ENV[os_env_var].nil? )
      if ENV[os_env_var].nil?
        unset_env_var <<  os_env_var
        is_config = false
      end
    end
  err_msg = "Please set #{unset_env_var.join(', ')} environment"
  err_msg = err_msg + ( unset_env_var.length > 1 ? " varriables for integration tests." : " varriable for integration tests." )
  puts err_msg unless unset_env_var.empty?
  is_config
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
