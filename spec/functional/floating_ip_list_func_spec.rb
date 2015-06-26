#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
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
require 'chef/knife/openstack_floating_ip_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackFloatingIpList do
  let (:instance) {Chef::Knife::Cloud::OpenstackFloatingIpList.new}

  context 'functionality' do
    before do
      resources = [ TestResource.new({ "id" => "floatingip1", "instance_id" => "daed9e86-4b69-4242-993a-926a39352783", "ip" => "173.236.251.98", "fixed_ip" => "", "pool" => "test-pool"}
),
                    TestResource.new({ "id" => "floatingip2", "instance_id" => "", "ip" => "67.205.60.122", "fixed_ip" => "10.10.10.1", "pool" => "test-pool" }
)
                   ]
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:puts)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:validate!)
      instance.config[:format] = "summary"
    end

    it "lists formatted list of resources" do
      expect(instance.ui).to receive(:list).with(['ID', 'Instance ID', 'IP Address', 'Fixed IP', 'Floating IP Pool',
                                             'floatingip1', 'daed9e86-4b69-4242-993a-926a39352783', '173.236.251.98', '', 'test-pool',
                                             'floatingip2','', '67.205.60.122', '10.10.10.1', 'test-pool'], :uneven_columns_across, 5)
      instance.run
    end
  end
end