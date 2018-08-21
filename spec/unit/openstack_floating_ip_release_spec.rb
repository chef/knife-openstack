#
#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright 2013-2018 Chef Software, Inc.
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
require "chef/knife/openstack_floating_ip_release"
require "chef/knife/cloud/openstack_service"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OpenstackFloatingIpRelease do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackFloatingIpRelease.new
  include_context "#validate!", Chef::Knife::Cloud::OpenstackFloatingIpRelease.new

  before(:each) do
    @instance = Chef::Knife::Cloud::OpenstackFloatingIpRelease.new
    allow(@instance.ui).to receive(:error)
    @instance.name_args = ["23849038438240934n3294839248"]
  end

  describe "create service instance" do
    it "return OpenstackService instance" do
      expect(@instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end
  end

  describe "release floating ip" do
    it "calls release address" do
      address_id = "23849038438240934n3294839248"
      @instance.service = double
      response = OpenStruct.new(status: 202)
      expect(@instance.service).to receive(:release_address).and_return(response)
      expect(@instance.ui).to receive(:info).and_return("Floating IP released successfully.")
      @instance.execute_command
    end
  end
end
