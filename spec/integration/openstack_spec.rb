# Copyright: Copyright (c) 2013 Opscode, Inc.
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

# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def append_openstack_creds(is_list_cmd = false)
  openstack_creds_cmd = " --openstack-username '#{ENV['OPENSTACK_USERNAME']}' --openstack-password '#{ENV['OPENSTACK_PASSWORD']}' --openstack-api-endpoint #{ENV['OPENSTACK_AUTH_URL']}"
  openstack_creds_cmd = openstack_creds_cmd + " -c #{temp_dir}/knife.rb"
  if(!is_list_cmd)
    openstack_creds_cmd = openstack_creds_cmd + " --openstack-tenant #{ENV['OPENSTACK_TENANT']}"
  end
  openstack_creds_cmd
end

def append_openstack_creds_for_windows
  openstack_creds_cmd = " --openstack-username '#{ENV['OPENSTACK_USERNAME']}' --openstack-password '#{ENV['OPENSTACK_PASSWORD']}' --openstack-api-endpoint #{ENV['OPENSTACK_AUTH_URL']} "   
  openstack_creds_cmd = openstack_creds_cmd + " -c #{temp_dir}/knife.rb"
  openstack_creds_cmd = openstack_creds_cmd + " --openstack-tenant #{ENV['OPENSTACK_TENANT']}"
  openstack_creds_cmd
end

def get_ssh_credentials
  " --ssh-user #{@os_ssh_user}"+
  " --openstack-ssh-key-id #{@openstack_key_pair}"
end

def get_ssh_credentials_for_windows_image
  " --ssh-user #{@os_windows_ssh_user}"+
  " --ssh-password #{@os_windows_ssh_password}"+
  " --openstack-ssh-key-id #{@openstack_key_pair}"
end

def get_winrm_credentials
  " --winrm-user #{@os_winrm_user}"+
  " --winrm-password #{@os_winrm_password}"+
  " --openstack-ssh-key-id #{@openstack_key_pair}"
end

def rm_known_host
  known_hosts = File.expand_path("~") + "/.ssh/known_hosts"
  FileUtils.rm_rf(known_hosts)
end

describe 'knife-openstack' , :if => is_config_present do
  include KnifeTestBed
  include RSpec::KnifeTestUtils

  before(:all) do
    run('gem build knife-openstack.gemspec').exitstatus.should == 0
    run("gem install #{get_gem_file_name}").exitstatus.should == 0
    init_openstack_test
  end

  after(:all) do
    run("gem uninstall knife-openstack -v '#{Knife::OpenStack::VERSION}'")
    cleanup_test_data
  end

  context 'gem' do

    describe 'knife' do
      context 'openstack' do
        context 'flavor list --help' do
         let(:command) { "knife openstack flavor list --help" }
           it 'should list all the options available for flavors list command.' do
            match_stdout(/--help/)
          end
        end

        context 'group list --help' do
         let(:command) { "knife openstack group list --help" }
           it 'should list all the options available for group list command.' do
            match_stdout(/--help/)
          end
        end

        context 'image list --help' do
         let(:command) { "knife openstack image list --help" }
           it 'should list all the options available for image list command.' do
            match_stdout(/--help/)
          end
        end

        context 'server create --help' do
         let(:command) { "knife openstack server create --help" }
           it 'should list all the options available for server create command.' do
            match_stdout(/--help/)
          end
        end

        context 'server delete --help' do
         let(:command) { "knife openstack server delete --help" }
           it 'should list all the options available for server delete command.' do
            match_stdout(/--help/)
          end
        end

        context 'server list --help' do
         let(:command) { "knife openstack server list --help" }
           it 'should list all the options available for server list command.' do
            match_stdout(/--help/)
          end
        end
      end
    end

    describe 'Linux Platform Tests - knife'  do
      before(:each) {rm_known_host}
      context 'create server with standard options' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds + " --sudo"}
        after(:each)  { cmd_out = "#{cmd_stdout}" }
        it 'should successfully create the server with the provided options.' do
          match_status("should succeed")
        end

        context "delete server after create" do
          let(:command) { delete_instance_cmd(cmd_out) }
          it "should successfully delete the server." do
            match_status("should succeed")
          end
        end
      end

      context 'create server by using standard options and chef node name prefix default value(i.e openstack)' do
        cmd_out = ""
        let(:command) { "knife openstack server create "+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds + " --sudo"}
        after(:each)  {  run(delete_instance_cmd("#{cmd_stdout}"))  }
        it 'should successfully create the server with the provided options.' do
          match_status("should succeed")
        end
      end

      context 'create server by using standard options and chef node name prefix user specified value' do
        cmd_out = ""
        let(:command) { "knife openstack server create "+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        " --chef-node-name-prefix os-integration-test-" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds + " --sudo"}
        after(:each)  {  run(delete_instance_cmd("#{cmd_stdout}"))  }
        it 'should successfully create the server with the provided options.' do
          match_status("should succeed")
        end
      end

      context 'create server by using standard options and delete-server-on-failure' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        " --delete-server-on-failure" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds + " --sudo"}
        after(:each)  {  run(delete_instance_cmd("#{cmd_stdout}"))  }
        it 'should successfully create the server with the provided options.' do
          match_status("should succeed")
        end
      end

      context 'create server by using standard options and delete-server-on-failure' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        " --delete-server-on-failure" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/incorrect_openstack.pem"+
        append_openstack_creds() + " --sudo" }
        it 'should delete server on bootstrap failure' do
          match_status("should fail")
        end
      end

      context 'create server without openstack credentials' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem --sudo" }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server without ssh parameters' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        append_openstack_creds() + " --sudo" }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid security group' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --groups #{SecureRandom.hex(4)}"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid image id' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{SecureRandom.hex(18)} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid flavor id' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_invalid_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid key_pair name' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --ssh-user #{@os_ssh_user}"+
        " --openstack-ssh-key-id #{SecureRandom.hex(6)}"+
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with incorrect key_pair file' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --ssh-user #{@os_ssh_user}"+
        " --openstack-ssh-key-id #{@openstack_key_pair}"+
        " --identity-file #{temp_dir}/incorrect_openstack.pem"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw AuthenticationFailed Error message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with --openstack-private-network option' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --openstack-private-network"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should bootstrap sucessfully with private ip address.' do
          pending "not yet done"
          match_status("should succeed")
        end
      end

      context 'create server with --openstack-floating-ip option' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_linux_image} -f #{@os_linux_flavor} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --openstack-floating-ip"+
        append_openstack_creds() + " --sudo"}
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should associate a floating IP address to the new OpenStack node.' do
          pending 'empty floating ip pool'
          match_status("should succeed")
        end
      end
    end

    describe 'Windows Platform Tests - knife'  do
      before(:each) {rm_known_host}
      context 'create server (for windows) with standard options' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes --server-create-timeout 1800" +
        get_winrm_credentials+
        append_openstack_creds_for_windows() }
        after(:each)  { cmd_out = "#{cmd_stdout}" }

        it 'should successfully create the (windows VM) server with the provided options.' do
          match_status("should succeed")
        end

        context "delete server after create" do
          let(:command) { delete_instance_cmd(cmd_out) }
          it "should successfully delete the server." do
            pending 'run windows tests later'
            match_status("should succeed")
          end
        end
      end

      context 'create server (for windows) with standard options and chef node name prefix default value(i.e openstack)' do
        cmd_out = ""
        let(:command) { "knife openstack server create " +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes --server-create-timeout 1800" +
        get_winrm_credentials+
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should successfully create the (windows VM) server with the provided options.' do
          match_status("should succeed")
        end
      end

      context 'create server (for windows) with standard options and chef node name prefix user specified value' do
        cmd_out = ""
        let(:command) { "knife openstack server create " +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --chef-node-name-prefix os-integration-test-"  +
        " --yes --server-create-timeout 1800" +
        get_winrm_credentials+
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should successfully create the (windows VM) server with the provided options.' do
          match_status("should succeed")
        end
      end

      context 'create server (for windows) with standard options and delete-server-on-failure' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --delete-server-on-failure" +
        " --yes --server-create-timeout 1800" +
        get_winrm_credentials+
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should successfully create the (windows VM) server with the provided options.' do
          match_status("should succeed")
        end
      end

      context 'create server (for windows) with standard options and delete-server-on-failure' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol invalid_bootstrap_protocol" +
        " --delete-server-on-failure" +
        " --yes --server-create-timeout 1800" +
        get_winrm_credentials +
        append_openstack_creds_for_windows() }
        it 'should delete created (windows VM) server on bootstrap failure.' do
          match_status("should fail")
        end
      end

      context 'create server (for windows) without openstack credentials' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889 --image-os-type windows" +
        " --bootstrap-protocol winrm" +
        " --yes" +
        get_winrm_credentials }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid winrm user' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes --server-create-timeout 1800" +
        " --winrm-user #{SecureRandom.hex(6)}"+
        " --winrm-password #{@os_winrm_password}" +
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should fail to bootstrap and stop execution.' do
          pending "Fails due to OC-9708 bug in knife-windows."
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid winrm password' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@os_windows_image} " +
        " -f #{@os_windows_flavor} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes  --server-create-timeout 1800" +
        " --winrm-user #{@os_winrm_user}"+
        " --winrm-password #{SecureRandom.hex(6)}" +
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should fail to bootstrap and stop execution.' do
          pending "Fails due to OC-9708 bug in knife-windows."
          match_status("should fail")
        end
      end

      context 'create server (for windows) using a ssh enabled windows image with ssh parameters and valid image-os-type' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_ssh_image}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --openstack-ssh-key-id #{@openstack_key_pair}"+
        get_ssh_credentials_for_windows_image+
        append_openstack_creds() + " --image-os-type windows" }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'successfully create the (windows VM) server with the provided options and bootstrap.' do
          match_status("should succeed")
        end
      end

      context 'create server (for windows) using a ssh enabled windows image with ssh parameters and invalid image-os-type' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_ssh_image}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes --server-create-timeout 1800" +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --ssh-key #{@openstack_key_pair}"+
        get_ssh_credentials_for_windows_image+
        append_openstack_creds() + " --image-os-type invalid" }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'successfully create the (windows VM) server with the provided options and bootstrap.' do
          match_status("should fail")
        end
      end      

      context 'create server (for windows) without ssh parameters' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_ssh_image}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889 --image-os-type windows" +
        " --yes" +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid security group' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_image}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --groups #{SecureRandom.hex(4)}"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid image id' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{SecureRandom.hex(18)}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid flavor id' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_image}"+
        " -f #{@os_invalid_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server (for windows) with --openstack-private-network option' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_image}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889 " +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        " --openstack-private-network"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should bootstrap sucessfully with private ip address.' do
          pending "not yet done"
          match_status("should succeed")
        end
      end

      context 'create server (for windows) with --openstack-floating-ip option' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@os_windows_image}"+
        " -f #{@os_windows_flavor} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        " --openstack-floating-ip"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should associate a floating IP address to the new OpenStack node.' do
          pending 'empty floating ip pool'
          match_status("should succeed")
        end
      end
    end

      context 'server list' do
        let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the servers.' do
          match_status("should succeed")
        end
      end

      context 'server list and chef-data' do
        let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) + " --chef-data" }
        it 'should successfully list all the servers.' do
          pending('setup a chef-zero on workspace node')
          match_status("should succeed")
        end
      end

      context 'server list and chef-data option with valid chef-node-attribute' do
        let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) + " --chef-data --chef-node-attribute platform_family" }
        it 'should successfully list all the servers.' do
          pending('setup a chef-zero on workspace node')
          match_status("should succeed")
        end
      end

      context 'server list and chef-data option with invalid chef-node-attribute' do
        let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) + " --chef-data --chef-node-attribute invalid" }
        it 'should successfully list all the servers.' do
          pending('setup a chef-zero on workspace node')
          match_status("should fail")
        end
      end

      context 'flavor list' do
        let(:command) { "knife openstack flavor list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the available flavors.' do
          match_status("should succeed")
        end
      end

      context 'image list' do
        let(:command) { "knife openstack image list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the available images.' do
          match_status("should succeed")
        end
      end

      context 'group  list' do
        let(:command) { "knife openstack group list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the available security groups.' do
          match_status("should succeed")
        end
      end

  end
end
