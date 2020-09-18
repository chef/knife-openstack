#
#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Copyright:: Copyright (c) Chef Software Inc.
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

require File.expand_path("../spec_helper", __dir__)
require "chef/knife/openstack_server_delete"
require "chef/knife/cloud/openstack_service"

describe Chef::Knife::Cloud::OpenstackServerDelete do
  before do
    @openstack_connection = double(Fog::OpenStack::Compute)
    @chef_node = double(Chef::Node)
    @chef_client = double(Chef::ApiClient)
    @knife_openstack_delete = Chef::Knife::Cloud::OpenstackServerDelete.new
    {
      openstack_username: "openstack_username",
      openstack_password: "openstack_password",
      openstack_auth_url: "openstack_auth_url",
    }.each do |key, value|
      @knife_openstack_delete.config[key] = value
    end

    @openstack_service = Chef::Knife::Cloud::OpenstackService.new(config: @knife_openstack_delete.config)
    allow(@openstack_service).to receive(:msg_pair)
    allow(@knife_openstack_delete).to receive(:create_service_instance).and_return(@openstack_service)
    allow(@knife_openstack_delete.ui).to receive(:warn)
    allow(@knife_openstack_delete.ui).to receive(:confirm)
    @openstack_servers = double
    @running_openstack_server = double
    @openstack_server_attribs = { name: "Mock Server",
                                  id: "id-123456",
                                  flavor: "flavor_id",
                                  image: "image_id",
                                  addresses: {
                                    "public" => [{ "addr" => "75.101.253.10" }],
                                    "private" => [{ "addr" => "10.251.75.20" }],
                                  },
                                }

    @openstack_server_attribs.each_pair do |attrib, value|
      allow(@running_openstack_server).to receive(attrib).and_return(value)
    end
    @knife_openstack_delete.name_args = ["test001"]
  end

  describe "run" do
    it "deletes an OpenStack instance." do
      expect(@openstack_servers).to receive(:get).and_return(@running_openstack_server)
      expect(@openstack_connection).to receive(:servers).and_return(@openstack_servers)
      expect(Fog::OpenStack::Compute).to receive(:new).and_return(@openstack_connection)
      expect(@running_openstack_server).to receive(:destroy)
      @knife_openstack_delete.run
    end

    it "deletes the instance along with the node and client on the chef-server when --purge is given as an option." do
      @knife_openstack_delete.config[:purge] = true
      expect(Chef::Node).to receive(:load).and_return(@chef_node)
      expect(@chef_node).to receive(:destroy)
      expect(Chef::ApiClient).to receive(:load).and_return(@chef_client)
      expect(@chef_client).to receive(:destroy)
      expect(@openstack_servers).to receive(:get).and_return(@running_openstack_server)
      expect(@openstack_connection).to receive(:servers).and_return(@openstack_servers)
      expect(Fog::OpenStack::Compute).to receive(:new).and_return(@openstack_connection)
      expect(@running_openstack_server).to receive(:destroy)
      @knife_openstack_delete.run
    end
  end
end
