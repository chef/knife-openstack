#
#
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Copyright:: Copyright 2013-2020 Chef Software, Inc.
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
require "chef/knife/openstack_server_show"
require "chef/knife/cloud/openstack_service"

describe Chef::Knife::Cloud::OpenstackServerShow do
  context "functionality" do
    before do
      @instance = Chef::Knife::Cloud::OpenstackServerShow.new
      Chef::Config[:knife][:instance_id] = "instance_id"
      @openstack_service = Chef::Knife::Cloud::OpenstackService.new
      allow(@openstack_service).to receive(:msg_pair)
      allow(@openstack_service).to receive(:print)
      allow_message_expectations_on_nil
      server = Object.new
      conn = Object.new
      conn.define_singleton_method(:servers) {}
      allow(@openstack_service).to receive(:connection).and_return(conn)
      expect(@openstack_service.connection.servers).to receive(:get).and_return(server)
      allow(@instance).to receive(:create_service_instance).and_return(@openstack_service)
      allow(@instance).to receive(:validate!)
      expect(@openstack_service).to receive(:server_summary)
    end

    it "runs server show successfully" do
      @instance.run
    end
  end
end
