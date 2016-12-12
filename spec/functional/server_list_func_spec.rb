#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
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
require "chef/knife/openstack_server_list"
require "chef/knife/cloud/openstack_service"

describe Chef::Knife::Cloud::OpenstackServerList do
  let (:instance) { Chef::Knife::Cloud::OpenstackServerList.new }

  context "functionality" do
    before do
      @resources = [TestResource.new(id: "resource-1", name: "ubuntu01", availability_zone: "test zone", addresses: { "public" => [{ "version" => 4, "addr" => "172.31.6.132" }], "private" => [{ "version" => 4, "addr" => "172.31.6.133" }] }, flavor: { "id" => "1" }, image: { "id" => "image1" }, key_name: "keypair", state: "ACTIVE"),
                    TestResource.new(id: "resource-2", name: "windows2008", availability_zone: "test zone", addresses: { "public" => [{ "version" => 4, "addr" => "172.31.6.132" }] }, flavor: { "id" => "id2" }, image: { "id" => "image2" }, key_name: "keypair", state: "ACTIVE"),
                    TestResource.new(id: "resource-3-err", name: "windows2008", availability_zone: "test zone", addresses: { "public" => [], "private" => [] }, flavor: { "id" => "id2" }, image: { "id" => "image2" }, key_name: "keypair", state: "ERROR"),
                   ]
      allow(instance).to receive(:query_resource).and_return(@resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::FogService.new)
      allow(instance).to receive(:validate!)
      instance.config[:format] = "summary"
    end

    it "lists formatted list of resources" do
      expect(instance.ui).to receive(:list).with(["Name", "Instance ID", "Addresses", "Flavor", "Image", "Keypair", "State", "Availability Zone",
                                                  "ubuntu01", "resource-1", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone",
                                                  "windows2008", "resource-2", "public:IPv4: 172.31.6.132", "id2", "image2", "keypair", "ACTIVE", "test zone",
                                                  "windows2008", "resource-3-err", "", "id2", "image2", "keypair", "ERROR", "test zone"], :uneven_columns_across, 8)
      instance.run
    end

    context "when chef-data and chef-node-attribute set" do
      before(:each) do
        @resources.push(TestResource.new(id: "server-4", name: "server-4", availability_zone: "test zone", addresses: { "public" => [{ "version" => 4, "addr" => "172.31.6.132" }], "private" => [{ "version" => 4, "addr" => "172.31.6.133" }] }, flavor: { "id" => "1" }, image: { "id" => "image1" }, key_name: "keypair", state: "ACTIVE"))
        @node = TestResource.new(id: "server-4", name: "server-4", chef_environment: "_default", fqdn: "testfqdnnode.us", run_list: [], tags: [], platform: "ubuntu", platform_family: "debian")
        allow(Chef::Node).to receive(:list).and_return("server-4" => @node)
        instance.config[:chef_data] = true
      end

      it "lists formatted list of resources on chef data option set" do
        expect(instance.ui).to receive(:list).with(["Name", "Instance ID", "Addresses", "Flavor", "Image", "Keypair", "State", "Availability Zone", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform",
                                                    "server-4", "server-4", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone", "server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu",
                                                    "ubuntu01", "resource-1", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "",
                                                    "windows2008", "resource-2", "public:IPv4: 172.31.6.132", "id2", "image2", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "",
                                                    "windows2008", "resource-3-err", "", "id2", "image2", "keypair", "ERROR", "test zone", "", "", "", "", "", ""], :uneven_columns_across, 14)
        instance.run
      end

      it "lists formatted list of resources on chef-data and chef-node-attribute option set" do
        instance.config[:chef_node_attribute] = "platform_family"
        expect(@node).to receive(:attribute?).with("platform_family").and_return(true)
        expect(instance.ui).to receive(:list).with(["Name", "Instance ID", "Addresses", "Flavor", "Image", "Keypair", "State", "Availability Zone", "Chef Node Name", "Environment", "FQDN", "Runlist", "Tags", "Platform", "platform_family",
                                                    "server-4", "server-4", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone", "server-4", "_default", "testfqdnnode.us", "[]", "[]", "ubuntu", "debian",
                                                    "ubuntu01", "resource-1", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "", "",
                                                    "windows2008", "resource-2", "public:IPv4: 172.31.6.132", "id2", "image2", "keypair", "ACTIVE", "test zone", "", "", "", "", "", "", "",
                                                    "windows2008", "resource-3-err", "", "id2", "image2", "keypair", "ERROR", "test zone", "", "", "", "", "", "", ""], :uneven_columns_across, 15)
        instance.run
      end

      it "raise error on invalid chef-node-attribute set" do
        instance.config[:chef_node_attribute] = "invalid_attribute"
        expect(instance.ui).to receive(:fatal)
        expect(@node).to receive(:attribute?).with("invalid_attribute").and_return(false)
        expect(instance.ui).to receive(:error).with("The Node does not have a invalid_attribute attribute.")
        expect { instance.run }.to raise_error
      end

      it "not display chef-data on chef-node-attribute set but chef-data option missing" do
        instance.config[:chef_data] = false
        instance.config[:chef_node_attribute] = "platform_family"
        expect(instance.ui).to receive(:list).with(["Name", "Instance ID", "Addresses", "Flavor", "Image", "Keypair", "State", "Availability Zone",
                                                    "server-4", "server-4", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone",
                                                    "ubuntu01", "resource-1", "public:IPv4: 172.31.6.132", "1", "image1", "keypair", "ACTIVE", "test zone",
                                                    "windows2008", "resource-2", "public:IPv4: 172.31.6.132", "id2", "image2", "keypair", "ACTIVE", "test zone",
                                                    "windows2008", "resource-3-err", "", "id2", "image2", "keypair", "ERROR", "test zone"], :uneven_columns_across, 8)
        instance.run
      end
    end
  end
end
