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
  unset_env_var = []
  unset_config_options = []
  is_config = true
  is_config_file_present = File.exist?(File.expand_path("../integration/config/environment.yml", __FILE__))
  
  if(!is_config_file_present)
    puts "\nSkipping the integration tests for knife openstack commands"
    puts "\nPlease make sure environment.yml is present and set with valid credentials."
    puts "\nPlease look for a sample file at spec/integration/config/environment.yml.sample"
    puts "\nPlease make sure openstack.pem is present and set with valid key pair content. This content should match for key pair name mentioned in environment.yml at attribute 'key_pair: key_pair_name'"
    puts "\nBy default openstack.pem contains dummy key pair content.\n"
  end
 
  openstack_config = YAML.load(File.read(File.expand_path("../integration/config/environment.yml", __FILE__))) if is_config_file_present

  %w(OPENSTACK_USERNAME OPENSTACK_PASSWORD OPENSTACK_AUTH_URL OPENSTACK_TENANT).each do |os_env_var|
      if ENV[os_env_var].nil?
        unset_env_var <<  os_env_var
        is_config = false
      end
    end

  err_msg = "\nPlease set #{unset_env_var.join(', ')} environment"
  err_msg = err_msg + ( unset_env_var.length > 1 ? " varriables " : " varriable " ) + "for integration tests."
  puts err_msg unless unset_env_var.empty?
  
  %w(OS_SSH_USER OPENSTACK_KEY_PAIR OS_WINDOWS_SSH_USER OS_WINDOWS_SSH_PASSWORD OS_WINRM_USER OS_WINRM_PASSWORD OS_LINUX_IMAGE OS_LINUX_FLAVOR OS_INVALID_FLAVOR OS_WINDOWS_FLAVOR OS_WINDOWS_IMAGE OS_WINDOWS_SSH_IMAGE).each do |os_config_opt|
    option_value = (openstack_config[os_config_opt] if openstack_config) || ENV[os_config_opt]
    if option_value.nil?
      unset_config_options << os_config_opt
      is_config = false
    end
  end

  config_err_msg = "\nPlease set #{unset_config_options.join(', ')} config"
  config_err_msg = config_err_msg + ( unset_config_options.length > 1 ? " options in environment.yml or as environment varriables" : " option in environment.yml or as environment variable" ) + " for integration tests."
  puts config_err_msg unless unset_config_options.empty?
  
  is_config && is_config_file_present
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

  openstack_config = YAML.load(File.read(File.expand_path("../integration/config/environment.yml", __FILE__)))

  %w(OS_SSH_USER OPENSTACK_KEY_PAIR OS_WINDOWS_SSH_USER OS_WINDOWS_SSH_PASSWORD OS_WINRM_USER OS_WINRM_PASSWORD OS_LINUX_IMAGE OS_LINUX_FLAVOR OS_INVALID_FLAVOR OS_WINDOWS_FLAVOR OS_WINDOWS_IMAGE OS_WINDOWS_SSH_IMAGE).each do |os_config_opt|
    instance_variable_set("@#{os_config_opt.downcase}", (openstack_config[os_config_opt] if openstack_config) || ENV[os_config_opt])
  end  
end

# TODO - we should use factory girl or fixtures for this as part of test utils.
# Creates a resource class that can dynamically add attributes to
# instances and set the values
module JSONModule
  def to_json
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    hash.to_json
  end
  def from_json! string
    JSON.load(string).each do |var, val|
      self.instance_variable_set var, val
    end
  end
end

class TestResource
  include JSONModule
  def initialize(*args)
    args.each do |arg|
      arg.each do |key, value|
        add_attribute = "class << self; attr_accessor :#{key}; end"
        eval(add_attribute)
        eval("@#{key} = value")
      end
    end
  end
end
