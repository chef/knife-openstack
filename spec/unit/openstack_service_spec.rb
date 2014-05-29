#
# Copyright:: Copyright (c) 2011-2013 Chef Software, Inc.
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
#

require 'spec_helper'
require 'chef/knife/cloud/openstack_service'

describe Chef::Knife::Cloud::OpenstackService do
  describe "#add_api_endpoint" do
    before(:each) do
      @api_endpoint = "https://test_openstack_api_endpoint"
      Chef::Config[:knife][:api_endpoint] = @api_endpoint
      @instance = Chef::Knife::Cloud::OpenstackService.new
    end

    after(:each) do
      Chef::Config[:knife].delete(:api_endpoint)
    end

    it "sets the api_endpoint in auth params" do
      @instance.instance_variable_get(:@auth_params)[:openstack_auth_url].should == nil
      @instance.add_api_endpoint
      @instance.instance_variable_get(:@auth_params)[:openstack_auth_url].should == @api_endpoint
    end

    it "does not set the endpoint when --api-endpoint option is missing" do
      Chef::Config[:knife][:api_endpoint] = nil
      @instance.instance_variable_get(:@auth_params)[:openstack_auth_url].should == nil
      @instance.add_api_endpoint
      @instance.instance_variable_get(:@auth_params)[:openstack_auth_url].should_not == @api_endpoint
      @instance.instance_variable_get(:@auth_params)[:openstack_auth_url].should == nil
    end

    it "doesn't set an OpenStack endpoint type by default" do
      Chef::Config[:knife][:openstack_endpoint_type].should == nil
    end
  end

  describe "#get_server" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackService.new
      @instance.stub_chain(:connection,:servers,:get)
    end

    context "when instance_id given" do 
      it "return server" do
        server_id = "123f456-123-453e-9c0c-12345a6789"
        @instance.connection.servers.should_receive(:get).and_return(server_id)
        @instance.connection.servers.should_not_receive(:all)
        @instance.get_server(server_id).should == server_id
      end
    end

    context "when instance_name given" do
      before(:each) do
        @instance.connection.servers.should_receive(:get).and_return(nil)
      end

      let (:server_name) { "testname" }

      it "return server" do
        @instance.connection.servers.should_receive(:all).with({:name=>server_name}).and_return([server_name])
        @instance.get_server(server_name).should == server_name
      end

      it "raise error if multiple server matches found for given instance name" do
        error_message = "Multiple server matches found for '#{server_name}', use an instance_id to be more specific."
        @instance.connection.servers.should_receive(:all).with({:name=>server_name}).and_return([server_name,server_name])
        @instance.stub_chain(:ui,:fatal)
        expect { @instance.get_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, error_message)
      end
    end
  end
end
