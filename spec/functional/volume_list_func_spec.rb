#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
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
require "chef/knife/openstack_volume_list"
require "chef/knife/cloud/openstack_service"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OpenstackVolumeList do
  let (:instance) { Chef::Knife::Cloud::OpenstackVolumeList.new }

  context "functionality" do
    before do
      resources = [TestResource.new(id: "volume-1", name: "big-disk-volume", status: "available", size: 1024, description: "This is the big disk"),
                   TestResource.new(id: "volume-2", name: "little-disk-volume", status: "in-use", size: 8, description: "This is the little disk"),
                  ]
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:validate!)
    end

    it "lists formatted list of resources" do
      expect(instance.ui).to receive(:list).with(["Name", "ID", "Status", "Size", "Description",
                                                  "big-disk-volume", "volume-1", "available", "1024 GB", "This is the big disk",
                                                  "little-disk-volume", "volume-2", "in-use", "8 GB", "This is the little disk"], :uneven_columns_across, 5)
      instance.run
    end
  end
end
