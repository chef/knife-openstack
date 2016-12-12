#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2013-2015 Chef Software, Inc.
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
require "chef/knife/openstack_floating_ip_allocate"
require "chef/knife/cloud/openstack_service"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OpenstackFloatingIpAllocate do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackFloatingIpAllocate.new
  include_context "#validate!", Chef::Knife::Cloud::OpenstackFloatingIpAllocate.new

  before(:each) do
    @instance = Chef::Knife::Cloud::OpenstackFloatingIpAllocate.new
    allow(@instance.ui).to receive(:error)
  end

  describe "create service instance" do
    it "return OpenstackService instance" do
      expect(@instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end
  end

  describe "allocate floating ip" do
    it "calls allocate address" do
      @instance.service = double
      expect(@instance.service).to receive(:allocate_address).and_return(true)
      @instance.execute_command
    end
  end

  describe "when user provides pool option " do
    it "allocates floating ip in user specified pool" do
      @instance = Chef::Knife::Cloud::OpenstackFloatingIpAllocate.new(["--pool", "test-pool"])
      @instance.service = Chef::Knife::Cloud::Service.new
      response = { floating_ip: { "id" => "test-id", "instance_id" => "test-instance-id", "floating_ip" => "127.0.0.1", "fixed_ip" => "nil", "pool" => "test-pool" } }
      expect(@instance.service).to receive(:allocate_address).and_return(response)
      @instance.execute_command
    end
  end
end
