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

require 'spec_helper'
require 'chef/knife/openstack_flavor_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackFlavorList do
  let (:instance) { Chef::Knife::Cloud::OpenstackFlavorList.new }

  context 'functionality' do
    before do
      resources = [TestResource.new(id: 'resource-1', name: 'm1.tiny', vcpus: '1', ram: 512, disk: 0),
                   TestResource.new(id: 'resource-2', name: 'm1-xlarge-bigdisk', vcpus: '8', ram: 16_384, disk: 50)
                  ]
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:validate!)
      instance.config[:format] = 'summary'
    end

    it 'lists formatted list of resources' do
      expect(instance.ui).to receive(:list).with(['Name', 'ID', 'Virtual CPUs', 'RAM', 'Disk',
                                                  'm1-xlarge-bigdisk', 'resource-2', '8', '16384 MB', '50 GB',
                                                  'm1.tiny', 'resource-1', '1', '512 MB', '0 GB'], :uneven_columns_across, 5)
      instance.run
    end
  end
end
