# frozen_string_literal: true
#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
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
require "chef/knife/openstack_image_list"
require "chef/knife/cloud/openstack_service"

describe Chef::Knife::Cloud::OpenstackImageList do
  let (:instance) { Chef::Knife::Cloud::OpenstackImageList.new }

  context "functionality" do
    before do
      resources = [TestResource.new(id: "resource-1", name: "image01", metadata: {}),
                   TestResource.new(id: "resource-2", name: "initrd", metadata: {}),
                  ]
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:validate!)
      instance.config[:format] = "summary"
    end

    it "displays formatted list of images, filtered by default" do
      expect(instance.ui).to receive(:list).with(["Name", "ID", "Snapshot",
                                                  "image01", "resource-1", "no"], :uneven_columns_across, 3)
      instance.run
    end

    it "lists all images when disable_filter = true" do
      instance.config[:disable_filter] = true
      expect(instance.ui).to receive(:list).with(["Name", "ID", "Snapshot",
                                                  "image01", "resource-1", "no",
                                                  "initrd", "resource-2", "no"], :uneven_columns_across, 3)
      instance.run
    end
  end
end
