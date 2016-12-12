# Copyright: Copyright (c) 2013-2014 Chef Software, Inc.
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

require "mixlib/shellout"

module CleanupTestResources
  def self.validate_params
    unset_env_var = []

    # OPENSTACK_USERNAME, OPENSTACK_PASSWORD and OPENSTACK_AUTH_URL are mandatory params to run knife openstack commands.
    %w{OPENSTACK_USERNAME OPENSTACK_PASSWORD OPENSTACK_AUTH_URL}.each do |os_env_var|
      unset_env_var << os_env_var if ENV[os_env_var].nil?
    end

    err_msg = "\nPlease set #{unset_env_var.join(', ')} environment"
    err_msg = err_msg + (unset_env_var.length > 1 ? " variables " : " variable ") + "to cleanup test resources."
    unless unset_env_var.empty?
      puts err_msg
      exit 1
    end
  end

  # Use Mixlib::ShellOut to run knife openstack commands.
  def self.run(command_line)
    shell_out = Mixlib::ShellOut.new("#{command_line}")
    shell_out.timeout = 3000
    shell_out.run_command
    shell_out
  end

  # Use knife openstack to delete servers.
  def self.cleanup_resources
    delete_resources = []

    # Openstack credentials use during knife openstack command run.
    openstack_creds = "--openstack-username '#{ENV['OPENSTACK_USERNAME']}' --openstack-password '#{ENV['OPENSTACK_PASSWORD']}' --openstack-api-endpoint #{ENV['OPENSTACK_AUTH_URL']}"

    # List all servers in openstack using knife openstack server list command.
    list_command = "knife openstack server list #{openstack_creds}"
    list_output = run(list_command)

    # Check command exitstatus. Non zero exitstatus indicates command execution fails.
    if list_output.exitstatus != 0
      puts "Cleanup Test Resources failed. Please check Openstack user name, password and auth url are correct. Error: #{list_output.stderr}."
      exit list_output.exitstatus
    else
      servers = list_output.stdout
    end

    # We use "os-integration-test-<platform>-<randomNumber>" pattern for server name during integration tests run. So use "os-integration-test-" pattern to find out servers created during integration tests run.
    servers.each_line do |line|
      if line.include?("os-integration-test-") || (line.include?("openstack-") && line.include?("opscode-ci-ssh"))
        # Extract and add instance id of server to delete_resources list.
        delete_resources << { "id" => line.split(" ").first, "name" => line.split(" ")[1] }
      end
    end

    # Delete servers
    delete_resources.each do |resource|
      delete_command = "knife openstack server delete #{resource['id']} #{openstack_creds} --yes"
      delete_output = run(delete_command)

      # check command exitstatus. Non zero exitstatus indicates command execution fails.
      if delete_output.exitstatus != 0
        puts "Unable to delete server #{resource['name']}: #{resource['id']}. Error: #{delete_output.stderr}."
      else
        puts "Deleted server #{resource['name']}: #{resource['id']}."
      end
    end
  end
end

CleanupTestResources.validate_params
CleanupTestResources.cleanup_resources
