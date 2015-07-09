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
require 'chef/knife/openstack_floating_ip_disassociate'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'
require 'ostruct'

describe Chef::Knife::Cloud::OpenstackFloatingIpDisassociate do
  before(:each) do
    @instance = Chef::Knife::Cloud::OpenstackFloatingIpDisassociate.new(["--instance-id", "23849038438240934n3294839248"])
    @instance.name_args = [ '127.0.0.1' ]
  end

  describe 'associate floating ip' do
    it 'calls associate address' do
      @instance.service = Chef::Knife::Cloud::Service.new
      response = OpenStruct.new(:status => 202)
      expect(@instance.service).to receive(:disassociate_address).with('23849038438240934n3294839248', '127.0.0.1').and_return(response)
      expect(@instance.ui).to receive(:info).and_return('Floating IP 127.0.0.1 disassociated with Instance 23849038438240934n3294839248')
      @instance.execute_command
    end
  end
end
