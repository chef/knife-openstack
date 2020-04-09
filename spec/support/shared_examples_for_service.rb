#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
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

require "chef/knife/cloud/service"

shared_examples_for Chef::Knife::Cloud::Service do |instance|

  describe "#connection" do
    it "creates a connection to fog service." do
      expect(instance).to receive(:add_api_endpoint)
      expect(Fog::Compute).to receive(:new)
      instance.connection
    end
  end

  describe "#delete_server" do
    it "deletes the server." do
      server = double
      allow(instance).to receive(:puts)
      allow(instance).to receive_message_chain(:connection, :servers, :get).and_return(server)
      expect(server).to receive(:name).ordered
      expect(server).to receive(:id).ordered
      allow(instance).to receive_message_chain(:ui, :confirm)
      expect(server).to receive(:destroy).ordered
      instance.delete_server(:server_name)
    end

    it "throws error message when the server cannot be located." do
      server_name = "invalid_server_name"
      error_message = "Could not locate server '#{server_name}'."
      allow(instance).to receive_message_chain(:connection, :servers, :get).and_return(nil)
      allow(instance).to receive_message_chain(:ui, :error).with(error_message)
      expect { instance.delete_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerDeleteError)
    end
  end

  describe "#create_server" do
    before do
      allow(instance).to receive(:puts)
      allow(instance).to receive(:print)
    end

    it "creates the server." do
      server = double
      allow(instance).to receive_message_chain(:connection, :servers, :create).and_return(server)
      allow(instance).to receive_message_chain(:ui, :color)
      expect(server).to receive(:wait_for)
      instance.create_server({ server_create_timeout: 600 })
    end
  end

  describe "#get_server" do
    it "return server." do
      server = double
      allow(instance).to receive_message_chain(:connection, :servers, :create).and_return(server)
      expect(instance.connection.servers).to receive(:get)
      instance.get_server("instance_id")
    end
  end

  describe "#server_summary" do
    it "show server details." do
      server = double
      instance.ui = double
      expect(instance.ui).to receive(:list)
      expect(server).to receive(:id)
      instance.server_summary(server, [{ label: "Instance ID", key: "id" }])
    end
  end
end
