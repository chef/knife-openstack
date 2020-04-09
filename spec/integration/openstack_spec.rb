#
# Copyright:: Copyright 2013-2020 Chef Software, Inc.
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
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

def append_openstack_creds(is_list_cmd = false)
  openstack_creds_cmd = " --openstack-username '#{ENV["OPENSTACK_USERNAME"]}' --openstack-password '#{ENV["OPENSTACK_PASSWORD"]}' --openstack-api-endpoint #{ENV["OPENSTACK_AUTH_URL"]}"
  openstack_creds_cmd += " -c #{temp_dir}/knife.rb"
  unless is_list_cmd
    openstack_creds_cmd += " --openstack-tenant #{ENV["OPENSTACK_TENANT"]}"
  end
  openstack_creds_cmd
end

def append_openstack_creds_for_windows
  openstack_creds_cmd = " --openstack-username '#{ENV["OPENSTACK_USERNAME"]}' --openstack-password '#{ENV["OPENSTACK_PASSWORD"]}' --openstack-api-endpoint #{ENV["OPENSTACK_AUTH_URL"]} "
  openstack_creds_cmd += " -c #{temp_dir}/knife.rb"
  openstack_creds_cmd += " --openstack-tenant #{ENV["OPENSTACK_TENANT"]}"
  openstack_creds_cmd
end

def get_ssh_credentials
  " --ssh-user #{@os_ssh_user}"\
  " --openstack-ssh-key-id #{@openstack_key_pair}"
end

def get_ssh_credentials_for_windows_image
  " --ssh-user #{@os_windows_ssh_user}"\
  " --ssh-password #{@os_windows_ssh_password}"\
  " --openstack-ssh-key-id #{@openstack_key_pair}"
end

def get_winrm_credentials
  " --winrm-user #{@os_winrm_user}"\
  " --winrm-password #{@os_winrm_password}"\
  " --openstack-ssh-key-id #{@openstack_key_pair}"
end

# get openstack active instance_id for knife openstack show command run
def get_active_instance_id
  server_list_output = run("knife openstack server list " + append_openstack_creds(is_list_cmd = true))
  # Check command exitstatus. Non zero exitstatus indicates command execution fails.
  if server_list_output.exitstatus != 0
    puts "Please check Openstack user name, password and auth url are correct. Error: #{list_output.stderr}."
    return false
  else
    servers = server_list_output.stdout
  end

  servers.each_line do |line|
    if line.include?("ACTIVE")
      instance_id = line.split(" ").first
      return instance_id
    end
  end
  false
end

describe "knife-openstack integration test", if: is_config_present do
  include KnifeTestBed
  include RSpec::KnifeTestUtils

  before(:all) do
    expect(run("gem build knife-openstack.gemspec").exitstatus).to be(0)
    expect(run("gem install #{get_gem_file_name}").exitstatus).to be(0)
    init_openstack_test
  end

  after(:all) do
    run("gem uninstall knife-openstack -v '#{Knife::OpenStack::VERSION}'")
    cleanup_test_data
  end

  describe "display help for command" do
    %w{flavor\ list server\ create server\ delete server\ list group\ list image\ list network\ list }.each do |command|
      context "when --help option used with #{command} command" do
        let(:command) { "knife openstack #{command} --help" }
        run_cmd_check_stdout("--help")
      end
    end
  end

  describe "display server list" do
    context "when standard options specified" do
      let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) }
      run_cmd_check_status_and_output("succeed", "Instance ID")
    end

    context "when --chef-data CLI option specified" do
      let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) + " --chef-data" }
      it { skip("setup a chef-zero on workspace node") }
    end

    context "when --chef-data and valid --chef-node-attribute CLI option specified" do
      let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) + " --chef-data --chef-node-attribute platform_family" }
      it { skip("setup a chef-zero on workspace node") }
    end

    context "when --chef-data and In valid --chef-node-attribute CLI option specified" do
      let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) + " --chef-data --chef-node-attribute invalid" }
      it { skip("setup a chef-zero on workspace node") }
    end
  end

  describe "display flavor list" do
    context "when standard options specified" do
      let(:command) { "knife openstack flavor list" + append_openstack_creds(is_list_cmd = true) }
      run_cmd_check_status_and_output("succeed", "ID")
    end
  end

  describe "display image list" do
    context "when standard options specified" do
      let(:command) { "knife openstack image list" + append_openstack_creds(is_list_cmd = true) }
      run_cmd_check_status_and_output("succeed", "ID")
    end
  end

  describe "display group list" do
    context "when standard options specified" do
      let(:command) { "knife openstack group list" + append_openstack_creds(is_list_cmd = true) }
      run_cmd_check_status_and_output("succeed", "Name")
    end
  end

  describe "display network list" do
    context "when standard options specified" do
      let(:command) { "knife openstack network list" + append_openstack_creds(is_list_cmd = true) }
      it { skip "Chef openstack setup not support this functionality" }
    end
  end

  describe "server show" do
    context "with valid instance_id" do
      before(:each) do
        @instance_id = get_active_instance_id
      end
      let(:command) { "knife openstack server show #{@instance_id}" + append_openstack_creds(is_list_cmd = true) }
      run_cmd_check_status_and_output("succeed", "Instance ID")
    end

    context "with invalid instance_id" do
      let(:command) { "knife openstack server show invalid_instance_id" + append_openstack_creds(is_list_cmd = true) }

      run_cmd_check_status_and_output("fail", "ERROR: Server doesn't exists for this invalid_instance_id instance id")
    end
  end

  describe "create and bootstrap Linux Server" do
    before(:each) { rm_known_host }
    context "when standard options specified" do
      cmd_out = ""

      before(:each) { create_node_name("linux") }

      after { cmd_out = "#{cmd_output}" }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")

      context "delete server after create" do
        let(:command) { delete_instance_cmd(cmd_out) }
        run_cmd_check_status_and_output("succeed", "#{@name_node}")
      end
    end

    context "when standard options and chef node name prefix is default value(i.e openstack)" do
      let(:command) do
        "knife openstack server create "\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      after { run(delete_instance_cmd("#{cmd_output}")) }

      run_cmd_check_status_and_output("succeed", "Bootstrapping Chef on")
    end

    context "when standard options and chef node name prefix is user specified value" do
      let(:command) do
        "knife openstack server create "\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --chef-node-name-prefix os-integration-test-" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      after { run(delete_instance_cmd("#{cmd_output}")) }

      run_cmd_check_status_and_output("succeed", "os-integration-test-")
    end

    context "when standard options and delete-server-on-failure specified" do
      nodename = ""
      before(:each) { create_node_name("linux") }

      after { nodename = @name_node }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --delete-server-on-failure" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")

      context "delete server by using name after create" do
        let(:command) { "knife openstack server delete #{nodename} " + append_openstack_creds(is_list_cmd = true) + " --yes" }
        run_cmd_check_status_and_output("succeed", "#{@name_node}")
      end
    end

    context "when delete-server-on-failure specified and bootstrap fails" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --delete-server-on-failure" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/incorrect_openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "FATAL: Authentication Failed during bootstrapping")
    end

    context "when openstack credentials not specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem --sudo"
      end

      run_cmd_check_status_and_output("fail", "ERROR: You did not provide a valid 'Openstack Username' value")
    end

    context "when ssh-password and identity-file parameters not specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          append_openstack_creds + " --sudo"
      end

      it { skip "Chef openstack setup not support this functionality." }
    end

    context "when standard options and invalid openstack security group specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem"\
          " --openstack-groups invalid-invalid-1212" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "Security group invalid-invalid-1212 not found")
    end

    context "when standard options and invalid image id specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{SecureRandom.hex(18)} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "ERROR: You have not provided a valid image ID. Please note the options for this value are -I or --image")
    end

    context "when standard options and invalid flavor id specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_invalid_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "ERROR: You have not provided a valid flavor ID. Please note the options for this value are -f or --flavor")
    end

    context "when standard options and invalid floating ip specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} --openstack-floating-ip #{@os_invalid_floating_ip} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "ERROR: You have either requested an invalid floating IP address or none are available")
    end

    context "when invalid key_pair specified" do
      before(:each) { create_node_name("linux") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" \
          " --ssh-user #{@os_ssh_user}"\
          " --openstack-ssh-key-id #{SecureRandom.hex(6)}"\
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "Invalid key_name provided")
    end

    context "when incorrect openstack private_key.pem file is used" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" \
          " --ssh-user #{@os_ssh_user}"\
          " --openstack-ssh-key-id #{@openstack_key_pair}"\
          " --identity-file #{temp_dir}/incorrect_openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("fail", "FATAL: Authentication Failed during bootstrapping")
    end

    context "when standard options and --openstack-private-network option specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem"\
          " --openstack-private-network" + append_openstack_creds + " --sudo"
      end

      it { skip "not yet supported" }
    end

    context "when standard options and --openstack-floating-ip option specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem"\
          " --openstack-floating-ip" + append_openstack_creds + " --sudo"
      end

      it { skip "empty floating ip pool" }
    end

    context "when standard options and user data specified" do
      before(:each) do
        create_node_name("linux")
        @user_data_file = create_sh_user_data_file
      end

      after do
        # check user_data exists in server def
        expect(cmd_output).to include("user_data=>\"#{@user_data_file.read}\"")
        delete_sh_user_data_file(@user_data_file)
        run(delete_instance_cmd("#{cmd_output}"))
      end

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" \
          " --user-data #{@user_data_file.path}" +
          append_openstack_creds + " --sudo -VV"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")
    end

    context "when standard options and no network option specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --no-network" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")
    end

    context "when standard options and openstack endpoint type option is specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --openstack-endpoint-type publicURL" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")
    end

    context "when standard options and openstack metadata option is specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --metadata testdataone='testmetadata'" +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem"\
          " --metadata testdatatwo='testmetadata'" +
          append_openstack_creds + " --sudo"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")
    end

    context "when standard options and openstack network-ids option is specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --network-ids #{@os_network_ids} " +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      it { skip "Chef openstack setup not support this functionality" }
    end

    context "when standard options and openstack availability-zone option is specified" do
      server_create_common_bfr_aftr

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_linux_image} -f #{@os_linux_flavor} "\
      " --template-file " + get_linux_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --availability-zone #{@os_availability_zone} " +
          get_ssh_credentials +
          " --identity-file #{temp_dir}/openstack.pem" + append_openstack_creds + " --sudo"
      end

      it { skip "Chef openstack setup not support this functionality" }
    end
  end

  describe "create and bootstrap Windows Server" do
    before(:each) { rm_known_host }

    context "when standard options specified" do
      cmd_out = ""

      before(:each) { create_node_name("windows") }

      let(:command) do
        "knife openstack server create -N #{@name_node}" \
      " -I #{@os_windows_image} " \
      " -f #{@os_windows_flavor} " \
      " --template-file " + get_windows_msi_template_file_path +
          " --server-url http://localhost:8889" \
          " --bootstrap-protocol winrm" \
          " --yes --server-create-timeout 1800" +
          get_winrm_credentials + append_openstack_creds_for_windows
      end

      after { cmd_out = "#{cmd_output}" }

      run_cmd_check_status_and_output("succeed", "#{@name_node}")

      context "delete server after create" do
        let(:command) { delete_instance_cmd(cmd_out) }
        run_cmd_check_status_and_output("succeed")
      end
    end

    context "when invalid winrm user specified" do
      server_create_common_bfr_aftr("windows")

      let(:command) do
        "knife openstack server create -N #{@name_node}" \
      " -I #{@os_windows_image} " \
      " -f #{@os_windows_flavor} " \
      " --template-file " + get_windows_msi_template_file_path +
          " --server-url http://localhost:8889" \
          " --bootstrap-protocol winrm" \
          " --yes --server-create-timeout 1800" \
          " --winrm-user #{SecureRandom.hex(6)}"\
          " --winrm-password #{@os_winrm_password}" +
          append_openstack_creds_for_windows
      end
      it { skip "Fails due to OC-9708 bug in knife-windows." }
    end

    context "when invalid winrm password specified" do
      server_create_common_bfr_aftr("windows")

      let(:command) do
        "knife openstack server create -N #{@name_node}" \
      " -I #{@os_windows_image} " \
      " -f #{@os_windows_flavor} " \
      " --template-file " + get_windows_msi_template_file_path +
          " --server-url http://localhost:8889" \
          " --bootstrap-protocol winrm" \
          " --yes  --server-create-timeout 1800" \
          " --winrm-user #{@os_winrm_user}"\
          " --winrm-password #{SecureRandom.hex(6)}" +
          append_openstack_creds_for_windows
      end
      after(:each) { run(delete_instance_cmd("#{cmd_output}")) }

      it { skip "Fails due to OC-9708 bug in knife-windows." }
    end

    context "when standard options ssh bootstrap and valid image-os-type protocol specified" do
      server_create_common_bfr_aftr("windows")

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_windows_ssh_image}"\
      " -f #{@os_windows_flavor} "\
      " --template-file " + get_windows_msi_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --identity-file #{temp_dir}/openstack.pem"\
          " --openstack-ssh-key-id #{@openstack_key_pair}" + get_ssh_credentials_for_windows_image + append_openstack_creds + " --image-os-type windows"
      end

      run_cmd_check_status_and_output("succeed", "#{@name_node}")
    end

    context "when standard options ssh bootstrap and invalid image-os-type protocol specified" do
      before(:each) { create_node_name("windows") }

      let(:command) do
        "knife openstack server create -N #{@name_node}"\
      " -I #{@os_windows_ssh_image}"\
      " -f #{@os_windows_flavor} "\
      " --template-file " + get_windows_msi_template_file_path +
          " --server-url http://localhost:8889" \
          " --yes --server-create-timeout 1800" \
          " --identity-file #{temp_dir}/openstack.pem"\
          " --openstack-ssh-key-id #{@openstack_key_pair}" + get_ssh_credentials_for_windows_image + append_openstack_creds + " --image-os-type invalid"
      end

      run_cmd_check_status_and_output("fail", "ERROR: You must provide --image-os-type option [windows/linux]")
    end
  end
end
