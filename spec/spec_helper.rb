#
# Copyright:: Copyright (c) Chef Software Inc.
# License: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "chef/knife/bootstrap"
require "chef/knife/openstack_helpers"
require "fog/openstack"
require "chef/knife/openstack_server_create"
require "chef/knife/openstack_server_delete"
require "securerandom"
require "knife-openstack/version"
require "test/knife-utils/test_bed"
require "resource_spec_helper"
require "server_command_common_spec_helper"
require "tempfile"
require "spec_context"

def find_instance_id(instance_name, file)
  file.lines.each do |line|
    return "#{line}".split(" ")[2].strip if line.include?("#{instance_name}")
  end
end

def is_config_present
  unless ENV["RUN_INTEGRATION_TESTS"]
    puts("\nPlease set RUN_INTEGRATION_TESTS environment variable to run integration tests")
    return false
  end

  unset_env_var = []
  unset_config_options = []
  is_config = true
  config_file_exist = File.exist?(File.expand_path("integration/config/environment.yml", __dir__))
  openstack_config = YAML.load(File.read(File.expand_path("integration/config/environment.yml", __dir__))) if config_file_exist
  %w{OPENSTACK_USERNAME OPENSTACK_PASSWORD OPENSTACK_AUTH_URL OPENSTACK_TENANT}.each do |os_env_var|
    if ENV[os_env_var].nil?
      unset_env_var << os_env_var
      is_config = false
    end
  end

  err_msg = "\nPlease set #{unset_env_var.join(", ")} environment"
  err_msg = err_msg + (unset_env_var.length > 1 ? " variables " : " variable ") + "for integration tests."
  puts err_msg unless unset_env_var.empty?

  %w{OS_SSH_USER OPENSTACK_PRI_KEY OPENSTACK_KEY_PAIR OS_WINDOWS_SSH_USER OS_WINDOWS_SSH_PASSWORD OS_WINRM_USER OS_WINRM_PASSWORD OS_LINUX_IMAGE OS_LINUX_FLAVOR OS_INVALID_FLAVOR OS_INVALID_FLOATING_IP OS_WINDOWS_FLAVOR OS_WINDOWS_IMAGE OS_WINDOWS_SSH_IMAGE OS_NETWORK_IDS OS_AVAILABILITY_ZONE}.each do |os_config_opt|
    option_value = ENV[os_config_opt] || (openstack_config[os_config_opt] if openstack_config)
    if option_value.nil?
      unset_config_options << os_config_opt
      is_config = false
    end
  end

  config_err_msg = "\nPlease set #{unset_config_options.join(", ")} config"
  config_err_msg = config_err_msg + (unset_config_options.length > 1 ? " options in ../spec/integration/config/environment.yml or as environment variables" : " option in ../spec/integration/config/environment.yml or as environment variable") + " for integration tests."
  puts config_err_msg unless unset_config_options.empty?

  is_config
end

def get_gem_file_name
  "knife-openstack-" + Knife::OpenStack::VERSION + ".gem"
end

def delete_instance_cmd(stdout)
  "knife openstack server delete " + find_instance_id("Instance ID", stdout) +
    append_openstack_creds(is_list_cmd = true) + " --yes"
end

def create_node_name(name)
  @name_node = (name == "linux") ? "os-integration-test-linux-#{SecureRandom.hex(4)}" : "os-integration-test-win-#{SecureRandom.hex(4)}"
end

def init_openstack_test
  init_test

  begin
    data_to_write = File.read(File.expand_path("integration/config/incorrect_openstack.pem", __dir__))
    File.open("#{temp_dir}/incorrect_openstack.pem", "w") { |f| f.write(data_to_write) }
  rescue
    puts "Error while creating file - incorrect_openstack.pem"
  end

  config_file_exist = File.exist?(File.expand_path("integration/config/environment.yml", __dir__))
  openstack_config = YAML.load(File.read(File.expand_path("integration/config/environment.yml", __dir__))) if config_file_exist

  %w{OS_SSH_USER OPENSTACK_KEY_PAIR OPENSTACK_PRI_KEY OS_WINDOWS_SSH_USER OS_WINDOWS_SSH_PASSWORD OS_WINRM_USER OS_WINRM_PASSWORD OS_LINUX_IMAGE OS_LINUX_FLAVOR OS_INVALID_FLAVOR OS_INVALID_FLOATING_IP OS_WINDOWS_FLAVOR OS_WINDOWS_IMAGE OS_WINDOWS_SSH_IMAGE OS_NETWORK_IDS OS_AVAILABILITY_ZONE}.each do |os_config_opt|
    instance_variable_set("@#{os_config_opt.downcase}", (openstack_config[os_config_opt] if openstack_config) || ENV[os_config_opt])
  end
  begin
    key_file_path = @openstack_pri_key
    key_file_exist = File.exist?(File.expand_path(key_file_path, __FILE__))
    data_to_write = File.read(File.expand_path(key_file_path, __FILE__)) if key_file_exist
    File.open("#{temp_dir}/openstack.pem", "w") { |f| f.write(data_to_write) }
  rescue
    puts "Error while creating file - openstack.pem"
  end
end

def create_sh_user_data_file
  file = Tempfile.new(["test_user_data", ".sh"])
  file.write("echo 'sample user data file created' >> #{Dir.tmpdir}/testuserdata.txt")
  file.rewind
  file
end

def delete_sh_user_data_file(file)
  file.close
  file.unlink
end

class UnexpectedSystemExit < RuntimeError
  def self.from(system_exit)
    new(system_exit.message).tap { |e| e.set_backtrace(system_exit.backtrace) }
  end
end

RSpec.configure do |c|
  c.raise_on_warning = true
  c.raise_errors_for_deprecations!

  c.before(:each) do
    Chef::Config.reset
  end

  c.around(:example) do |ex|

    ex.run
  rescue SystemExit => e
    raise UnexpectedSystemExit.from(e)

  end
end
