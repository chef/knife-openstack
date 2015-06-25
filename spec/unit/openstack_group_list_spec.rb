#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
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

require 'spec_helper'
require 'chef/knife/openstack_group_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackGroupList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackGroupList.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackGroupList.new

  let (:instance) {Chef::Knife::Cloud::OpenstackGroupList.new}

  context "#list" do
    before(:each) do
      @security_groups = [TestResource.new({ "name" => "Unrestricted","description" => "testdescription", "security_group_rules" => [TestResource.new({"from_port"=>636, "group"=>{}, "ip_protocol"=>"tcp", "to_port"=>636, "parent_group_id"=>14, "ip_range"=>{"cidr"=>"0.0.0.0/0"}, "id"=>183})]})]
      instance.config[:format] = "summary"
    end

    it "returns group list" do
      expect(instance.ui).to receive(:list).with(["Name", "Protocol", "From", "To", "CIDR", "Description", "Unrestricted", "tcp", "636", "636", "0.0.0.0/0", "testdescription"],:uneven_columns_across, 6)
      instance.list(@security_groups)
    end
  end
end
