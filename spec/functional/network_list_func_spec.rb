#
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.
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
require 'chef/knife/openstack_network_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackNetworkList do
  let (:instance) {Chef::Knife::Cloud::OpenstackNetworkList.new}

  context "functionality" do
    before do
      resources = [ TestResource.new({:id => "resource-1", :name => "external", :tenant_id => "1", :shared => true}),
                    TestResource.new({:id => "resource-2", :name => "internal", :tenant_id => "2", :shared => false})
                  ]
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:validate!)
      instance.config[:format] = "summary"
    end

    it "lists formatted list of network resources" do
      expect(instance.ui).to receive(:list).with(["Name", "ID", "Tenant", "Shared",
                                              "external", "resource-1", "1", "true",
                                              "internal", "resource-2", "2", "false"], :uneven_columns_across, 4)
      instance.run
    end
  end
end