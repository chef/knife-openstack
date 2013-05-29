# Copyright: Copyright (c) 2012 Opscode, Inc.
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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def append_openstack_creds(is_list_cmd = false)
  openstack_config = YAML.load(File.read(File.expand_path("../config/environment.yml", __FILE__)))
  openstack_creds_cmd = " --openstack-username #{openstack_config['development']['openstack_username']} --openstack-password #{openstack_config['development']['openstack_password']} --openstack-api-endpoint #{openstack_config['development']['openstack_auth_url']}"
  openstack_creds_cmd = openstack_creds_cmd + " -c #{temp_dir}/knife.rb"
  if(!is_list_cmd)
    openstack_creds_cmd = openstack_creds_cmd + " --openstack-tenant #{openstack_config['development']['openstack_tenant']}"
    openstack_creds_cmd = openstack_creds_cmd + " --ssh-user #{openstack_config['development']['ssh_user']}"
    openstack_creds_cmd = openstack_creds_cmd + " --ssh-key #{openstack_config['development']['key_pair']}"
    openstack_creds_cmd = openstack_creds_cmd + " --identity-file #{temp_dir}/openstack.pem"
  end
  openstack_creds_cmd
end

def delete_instance_cmd(stdout)
  "knife openstack server delete " + find_instance_id("Instance ID:", stdout) + 
  append_openstack_creds(is_list_cmd = true) + " --yes"
end

def create_node_name()
  @name_node  = "ostsp-#{SecureRandom.hex(4)}"
end

def linux_template_file_path
  "#{temp_dir}/chef-full-chef-zero.erb"
end

def init_test
  puts "\nCreating Test Data\n"
  create_file("#{temp_dir}", "validation.pem", "../integration/config/validation.pem" )
  create_file("#{temp_dir}", "chef-full-chef-zero.erb", "../integration/templates/chef-full-chef-zero.erb" )
  create_file("#{temp_dir}", "openstack.pem", "../integration/config/openstack.pem")
  create_file("#{temp_dir}", "knife.rb", "../integration/config/knife.rb")
end

def cleanup_test_data
  puts "\nCleaning Test Data\n"
  FileUtils.rm_rf("#{temp_dir}")
  puts "\nDone\n"
end

describe 'knife' do
  include RSpec::KnifeUtils
  before(:all) { init_test }
  after(:all) { cleanup_test_data }
  context 'openstack integration test - ' do
    context 'create server' do
      cmd_out = ""
      before(:each) { create_node_name }
      let(:command) { "knife openstack server create -N #{@name_node}"+
      " -I 9d155c01-1652-43bf-95f3-30893c40d423 -f 2"+
      " --template-file " + linux_template_file_path +
      " --server-url http://localhost:8889" +
      " --yes" +
      append_openstack_creds() }
      after(:each)  { cmd_out = "#{cmd_stdout}" }
      it 'should succeed' do
        match_status("should succeed")
      end

      context "delete server after create" do
        let(:command) { delete_instance_cmd(cmd_out) }      
        it "should succeed" do
          match_status("should succeed")
        end
      end
    end

    context 'server list' do
      let(:command) { "knife openstack server list" + append_openstack_creds(is_list_cmd = true) }
      it 'should succeed' do
        match_status("should succeed")
      end
    end

    context 'flavor list' do
      let(:command) { "knife openstack flavor list" + append_openstack_creds(is_list_cmd = true) }
      it 'should succeed' do
        match_status("should succeed")
      end
    end

    context 'image list' do
      let(:command) { "knife openstack image list" + append_openstack_creds(is_list_cmd = true) }
      it 'should succeed' do
        match_status("should succeed")
      end
    end

    context 'group  list' do
      let(:command) { "knife openstack group list" + append_openstack_creds(is_list_cmd = true) }
      it 'should succeed' do
        match_status("should succeed")
      end
    end

  end
end