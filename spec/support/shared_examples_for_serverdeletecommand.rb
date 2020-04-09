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

require "chef/knife/cloud/server/delete_command"

shared_examples_for Chef::Knife::Cloud::ServerDeleteCommand do |instance|
  describe "#delete_from_chef" do
    it "expects chef warning message when purge option is disabled" do
      server_name = "testserver"
      expect(instance.ui).to receive(:warn).with("Corresponding node and client for the #{server_name} server were not deleted and remain registered with the Chef Server")
      instance.delete_from_chef(server_name)
    end

    it "deletes chef node and client when purge option is enabled" do
      instance.config[:purge] = true
      server_name = "testserver"
      expect(instance).to receive(:destroy_item).with(Chef::Node, server_name, "node").ordered
      expect(instance).to receive(:destroy_item).with(Chef::ApiClient, server_name, "client").ordered
      instance.delete_from_chef(server_name)
    end

    it "deletes chef node specified with node-name option overriding the instance server_name" do
      instance.config[:purge] = true
      chef_node_name = "testnode"
      instance.config[:chef_node_name] = chef_node_name
      expect(instance).to receive(:destroy_item).with(Chef::Node, chef_node_name, "node").ordered
      expect(instance).to receive(:destroy_item).with(Chef::ApiClient, chef_node_name, "client").ordered
      instance.delete_from_chef(chef_node_name)
    end
  end

  describe "#execute_command" do
    it "execute with correct method calls" do
      instance.name_args = ["testserver"]
      instance.service = double
      expect(instance.service).to receive(:delete_server).ordered
      expect(instance).to receive(:delete_from_chef).ordered
      instance.execute_command
    end
  end

  describe "#destroy_item" do
    it "destroy chef node" do
      node_name = "testnode"
      test_obj = Object.new
      allow(Chef::Node).to receive(:load).and_return(test_obj)
      allow(test_obj).to receive(:destroy)
      expect(instance.ui).to receive(:warn).with("Deleted node #{node_name}")
      instance.destroy_item(Chef::Node, node_name, "node")
    end

    it "destroy chef client" do
      client_name = "testclient"
      test_obj = Object.new
      allow(Chef::ApiClient).to receive(:load).and_return(test_obj)
      allow(test_obj).to receive(:destroy)
      expect(instance.ui).to receive(:warn).with("Deleted client #{client_name}")
      instance.destroy_item(Chef::ApiClient, client_name, "client")
    end
  end
end
