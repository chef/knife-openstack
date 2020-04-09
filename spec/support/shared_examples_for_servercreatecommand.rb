#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013-2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
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

require "spec_helper"
require "chef/knife/cloud/server/create_command"

def get_mock_resource(id)
  obj = Object.new
  allow(obj).to receive(:id).and_return(id)
  obj
end

shared_examples_for Chef::Knife::Cloud::ServerCreateCommand do |instance|
  before do
    instance.service = double
    allow(instance.ui).to receive(:fatal)

    allow(instance.service).to receive(:get_image).and_return(get_mock_resource("image_id"))

    allow(instance.service).to receive(:get_flavor).and_return(get_mock_resource("flavor_id"))
  end

  describe "#before_exec_command" do
    it "calls create_server_dependencies" do
      expect(instance.service).to receive(:create_server_dependencies)
      instance.before_exec_command
    end
    it "delete_server_dependencies on any error" do
      allow(instance).to receive(:execute_command)
      allow(instance).to receive(:after_exec_command)
      allow(instance).to receive(:validate!)
      allow(instance).to receive(:validate_params!)
      instance.service = Chef::Knife::Cloud::Service.new
      allow(instance).to receive(:create_service_instance).and_return(instance.service)
      allow(instance.service).to receive(:get_image).and_return(get_mock_resource("image_id"))
      allow(instance.service).to receive(:get_flavor).and_return(get_mock_resource("flavor_id"))
      allow(instance.service).to receive(:create_server_dependencies).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateDependenciesError)
      expect(instance.service).to receive(:delete_server_dependencies)
      expect(instance.service).to_not receive(:delete_server_on_failure)
      expect(instance).to receive(:exit)
      instance.run
    end
  end

  describe "#execute_command" do
    it "calls create_server" do
      expect(instance.service).to receive(:create_server).and_return(true)
      expect(instance.service).to receive(:server_summary)
      instance.execute_command
    end

    it "delete_server_dependencies on any error" do
      allow(instance).to receive(:before_exec_command)
      allow(instance).to receive(:after_exec_command)
      allow(instance).to receive(:validate!)
      allow(instance).to receive(:validate_params!)
      instance.service = Chef::Knife::Cloud::Service.new
      allow(instance).to receive(:create_service_instance).and_return(instance.service)
      allow(instance.service).to receive(:create_server).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      expect(instance.service).to receive(:delete_server_dependencies)
      expect(instance.service).to_not receive(:delete_server_on_failure)
      expect(instance).to receive(:exit)
      instance.run
    end
  end

  describe "#bootstrap" do
    it "execute with correct method calls" do
      @bootstrap = Object.new
      allow(@bootstrap).to receive(:bootstrap)
      allow(instance.ui).to receive(:info)
      allow(Chef::Knife::Cloud::Bootstrapper).to receive(:new).and_return(@bootstrap)
      expect(instance).to receive(:before_bootstrap).ordered
      expect(instance).to receive(:after_bootstrap).ordered
      instance.bootstrap
    end
  end

  describe "#after_bootstrap" do
    it "display server summary" do
      expect(instance.service).to receive(:server_summary)
      instance.after_bootstrap
    end
  end

  describe "#get_node_name" do
    it "auto generates chef_node_name" do
      instance.config[:connection_protocol] = "ssh"
      instance.config[:connection_password] = "password"
      instance.config[:image_os_type] = "linux"
      instance.config[:chef_node_name_prefix] = "os"
      expect(instance).to receive(:get_node_name).and_call_original
      instance.validate_params!
      expect(instance.config[:chef_node_name]).to be =~ /os-*/
    end

    it "auto generates unique chef_node_name" do
      node_names = []
      instance.config[:connection_protocol] = "ssh"
      instance.config[:connection_password] = "password"
      instance.config[:image_os_type] = "linux"
      instance.config[:chef_node_name_prefix] = "os"
      5.times do
        instance.config[:chef_node_name] = nil
        instance.validate_params!
        expect(node_names).to_not include(instance.config[:chef_node_name])
        node_names.push(instance.config[:chef_node_name])
      end
    end
  end

  describe "#cleanup_on_failure" do
    it "delete server dependencies on delete_server_on_failure set" do
      instance.config[:delete_server_on_failure] = true
      instance.service = Chef::Knife::Cloud::Service.new
      expect(instance.service).to receive(:delete_server_dependencies)
      expect(instance.service).to receive(:delete_server_on_failure)
      instance.cleanup_on_failure
    end

    it "don't delete server dependencies on delete_server_on_failure option is missing" do
      instance.config[:delete_server_on_failure] = false
      Chef::Config[:knife].delete(:delete_server_on_failure)
      expect(instance.service).to_not receive(:delete_server_dependencies)
      expect(instance.service).to_not receive(:delete_server_on_failure)
      instance.cleanup_on_failure
    end
  end
end
