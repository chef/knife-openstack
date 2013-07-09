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
  openstack_creds_cmd = " --openstack-username #{@openstack_config['os_creds']['openstack_username']} --openstack-password #{@openstack_config['os_creds']['openstack_password']} --openstack-api-endpoint #{@openstack_config['os_creds']['openstack_auth_url']}"
  openstack_creds_cmd = openstack_creds_cmd + " -c #{temp_dir}/knife.rb"
  if(!is_list_cmd)
    openstack_creds_cmd = openstack_creds_cmd + " --openstack-tenant #{@openstack_config['os_creds']['openstack_tenant']}"
  end
  openstack_creds_cmd
end

def append_openstack_creds_for_windows
  openstack_creds_cmd = " --openstack-username #{@openstack_config['os_creds']['openstack_username']} --openstack-password #{@openstack_config['os_creds']['openstack_password']} --openstack-api-endpoint #{@openstack_config['os_creds']['openstack_auth_url']} "
  openstack_creds_cmd = openstack_creds_cmd + " -c #{temp_dir}/knife.rb"
  openstack_creds_cmd = openstack_creds_cmd + " --openstack-tenant #{@openstack_config['os_creds']['openstack_tenant']}"
  openstack_creds_cmd
end

def get_ssh_credentials
  " --ssh-user #{@openstack_config['os_ssh_params']['ssh_user']}"+
  " --ssh-key #{@openstack_config['os_ssh_params']['key_pair']}"
end

def get_ssh_credentials_for_windows_image
  " --ssh-user #{@openstack_config['os_ssh_params']['ssh_user_for_windows']}"+
  " --ssh-password #{@openstack_config['os_ssh_params']['ssh_password_for_windows']}"
end

def get_winrm_credentials
  " --winrm-user #{@openstack_config['os_winrm_params']['winrm_user']}"+
  " --winrm-password #{@openstack_config['os_winrm_params']['winrm_password']}"
end

describe 'knife-openstack' do
  include KnifeTestBed
  include RSpec::KnifeTestUtils

  before(:all) do
    @openstack_config = YAML.load(File.read(File.expand_path("../config/environment.yml", __FILE__)))
    init_openstack_test
  end
  after(:all) { cleanup_test_data }
  context 'gem' do
    context 'build' do
      let(:command) { "gem build knife-openstack.gemspec" }
      it 'should successfully build the knife-openstack gem using knife-openstack.gemspec.' do
        match_status("should succeed")
      end
    end

    context 'install ' do
      let(:command) { "gem install " + get_gem_file_name  }
      it 'should successfully install the gem on the target system.' do
        match_status("should succeed")
      end
    end

    describe 'knife' do
      context 'openstack' do
        context 'flavor list --help' do
         let(:command) { "knife openstack flavor list --help" }
           it 'should list all the options available for flavors list command.' do
            pending 'not yet implemented'
            match_stdout(/--help/)
          end
        end

        context 'group list --help' do
         let(:command) { "knife openstack group list --help" }
           it 'should list all the options available for group list command.' do
            pending 'not yet implemented'
            match_stdout(/--help/)
          end
        end

        context 'image list --help' do
         let(:command) { "knife openstack image list --help" }
           it 'should list all the options available for image list command.' do
            pending 'not yet implemented'
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
            pending 'not yet implemented'
            match_stdout(/--help/)
          end
        end
      end
    end

    describe 'Linux Platform Tests - knife' , :if => is_config_present do
      context 'create server with standard options' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds }
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

      context 'create server without openstack credentials' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"  }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server without ssh parameters' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid security group' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --groups #{SecureRandom.hex(4)}"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server with invalid image id' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{SecureRandom.hex(18)} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid flavor id' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['invalid_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with invalid key_pair name' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --ssh-user #{@openstack_config['os_ssh_params']['ssh_user']}"+
        " --ssh-key #{SecureRandom.hex(6)}"+
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with incorrect key_pair file' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --ssh-user #{@openstack_config['os_ssh_params']['ssh_user']}"+
        " --ssh-key #{@openstack_config['os_ssh_params']['key_pair']}"+
        " --identity-file #{temp_dir}/incorrect_openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw AuthenticationFailed Error message and stop execution.' do
          match_status("should fail")
        end
      end

      context 'create server with --private-network option' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --private-network"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should bootstrap sucessfully with private ip address.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

      context 'create server with --floating-ip option' do
        cmd_out = ""
        before(:each) { create_node_name("linux") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['linux_image']} -f #{@openstack_config['os_params']['linux_flavor']} "+
        " --template-file " + get_linux_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        get_ssh_credentials +
        " --identity-file #{temp_dir}/openstack.pem"+
        " --floating-ip"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should associate a floating IP address to the new OpenStack node.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end
    end

    describe 'Windows Platform Tests - knife' , :if => is_config_present do
      context 'create server (for windows) with standard options' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@openstack_config['os_params']['windows_image']} " +
        " -f #{@openstack_config['os_params']['windows_flavor']} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes" +
        get_winrm_credentials+
        append_openstack_creds_for_windows() }
        after(:each)  { cmd_out = "#{cmd_stdout}" }

        it 'should successfully create the (windows VM) server with the provided options.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end

        context "delete server after create" do
          let(:command) { delete_instance_cmd(cmd_out) }
          it "should successfully delete the server." do
            pending 'not yet implemented'
            match_status("should succeed")
          end
        end
      end

      context 'create server (for windows) without openstack credentials' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@openstack_config['os_params']['windows_image']} " +
        " -f #{@openstack_config['os_params']['windows_flavor']} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes" +
        get_winrm_credentials }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should throw validation message and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid winrm user' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@openstack_config['os_params']['windows_image']} " +
        " -f #{@openstack_config['os_params']['windows_flavor']} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes" +
        " --winrm-user #{SecureRandom.hex(6)}"+
        " --winrm-password #{@openstack_config['os_winrm_params']['winrm_password']}" +
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should fail to bootstrap and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid winrm password' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}" +
        " -I #{@openstack_config['os_params']['windows_image']} " +
        " -f #{@openstack_config['os_params']['windows_flavor']} " +
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --bootstrap-protocol winrm" +
        " --yes" +
        " --winrm-user #{@openstack_config['os_winrm_params']['winrm_user']}"+
        " --winrm-password #{SecureRandom.hex(6)}" +
        append_openstack_creds_for_windows() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should fail to bootstrap and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) using a ssh enabled windows image with ssh parameters' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['ssh_enabled_windows_image']}"+
        " -f #{@openstack_config['os_params']['windows_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --identity-file #{temp_dir}/openstack.pem"+
        get_ssh_credentials_for_windows_image+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'successfully create the (windows VM) server with the provided options and bootstrap.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

      context 'create server (for windows) without ssh parameters' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['ssh_enabled_windows_image']}"+
        " -f #{@openstack_config['os_params']['windows_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid security group' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['windows_image']}"+
        " -f #{@openstack_config['os_params']['windows_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --groups #{SecureRandom.hex(4)}"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }

        it 'should throw validation message and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid image id' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{SecureRandom.hex(18)}"+
        " -f #{@openstack_config['os_params']['windows_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) with invalid flavor id' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['windows_image']}"+
        " -f #{@openstack_config['os_params']['invalid_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should throw validation message and stop execution.' do
          pending 'not yet implemented'
          match_status("should fail")
        end
      end

      context 'create server (for windows) with --private-network option' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['windows_image']}"+
        " -f #{@openstack_config['os_params']['windows_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        " --private-network"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should bootstrap sucessfully with private ip address.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

      context 'create server (for windows) with --floating-ip option' do
        cmd_out = ""
        before(:each) { create_node_name("windows") }
        let(:command) { "knife openstack server create -N #{@name_node}"+
        " -I #{@openstack_config['os_params']['windows_image']}"+
        " -f #{@openstack_config['os_params']['windows_flavor']} "+
        " --template-file " + get_windows_msi_template_file_path +
        " --server-url http://localhost:8889" +
        " --yes" +
        " --bootstrap-protocol winrm" +
        get_winrm_credentials+
        " --identity-file #{temp_dir}/openstack.pem"+
        " --floating-ip"+
        append_openstack_creds() }
        after(:each)  { run(delete_instance_cmd("#{cmd_stdout}")) }
        it 'should associate a floating IP address to the new OpenStack node.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end
    end

      context 'server list' do
        let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the servers.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

      context 'flavor list' do
        let(:command) { "knife openstack flavor list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the available flavors.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

      context 'image list' do
        let(:command) { "knife openstack image list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the available images.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

      context 'group  list' do
        let(:command) { "knife openstack group list" + append_openstack_creds(is_list_cmd = true) }
        it 'should successfully list all the available security groups.' do
          pending 'not yet implemented'
          match_status("should succeed")
        end
      end

    context 'uninstall ' do
      let(:command) { "gem uninstall knife-openstack -v '#{Knife::OpenStack::VERSION}'" }
      it 'should successfully uninstall the gem from the system.' do
        match_status("should succeed")
      end
    end
  end
end
