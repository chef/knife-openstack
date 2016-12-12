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

require "spec_helper"
require "chef/knife/cloud/openstack_service"

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
      expect(@instance.instance_variable_get(:@auth_params)[:openstack_auth_url]).to be_nil
      @instance.add_api_endpoint
      expect(@instance.instance_variable_get(:@auth_params)[:openstack_auth_url]).to be == @api_endpoint
    end

    it "does not set the endpoint when --api-endpoint option is missing" do
      Chef::Config[:knife][:api_endpoint] = nil
      expect(@instance.instance_variable_get(:@auth_params)[:openstack_auth_url]).to be_nil
      @instance.add_api_endpoint
      expect(@instance.instance_variable_get(:@auth_params)[:openstack_auth_url]).to_not be == @api_endpoint
      expect(@instance.instance_variable_get(:@auth_params)[:openstack_auth_url]).to be_nil
    end

    it "doesn't set an OpenStack endpoint type by default" do
      expect(Chef::Config[:knife][:openstack_endpoint_type]).to be_nil
    end
  end

  describe "#get_server" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackService.new
      allow(@instance).to receive_message_chain(:connection, :servers, :get)
    end

    context "when instance_id given" do
      it "return server" do
        server_id = "123f456-123-453e-9c0c-12345a6789"
        expect(@instance.connection.servers).to receive(:get).and_return(server_id)
        expect(@instance.connection.servers).to_not receive(:all)
        expect(@instance.get_server(server_id)).to be == server_id
      end
    end

    context "when instance_name given" do
      before(:each) do
        expect(@instance.connection.servers).to receive(:get).and_return(nil)
      end

      let (:server_name) { "testname" }

      it "return server" do
        expect(@instance.connection.servers).to receive(:all).with(name: server_name).and_return([server_name])
        expect(@instance.get_server(server_name)).to be == server_name
      end

      it "raise error if multiple server matches found for given instance name" do
        error_message = "Multiple server matches found for '#{server_name}', use an instance_id to be more specific."
        expect(@instance.connection.servers).to receive(:all).with(name: server_name).and_return([server_name, server_name])
        allow(@instance).to receive_message_chain(:ui, :fatal)
        expect { @instance.get_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, error_message)
      end
    end
  end

  describe "#get_auth_params" do
    let(:auth_params) do
      Chef::Knife::Cloud::OpenstackService.new.instance_variable_get(:@auth_params)
    end

    it "sets ssl_verify_peer to false when openstack_insecure is true" do
      Chef::Config[:knife][:openstack_insecure] = true
      expect(auth_params[:connection_options][:ssl_verify_peer]).to be false
    end

    it "only copies openstack options from Fog" do
      params = auth_params.keys - [:provider, :connection_options]
      expect(params.all? { |p| p.to_s.start_with?("openstack") }).to be true
    end

    context "when openstack_password is set" do
      before(:each) do
        @expected = "password"
        Chef::Config[:knife][:openstack_password] = @expected
      end

      it "sets openstack_api_key from openstack_password" do
        expect(auth_params[:openstack_api_key]).to be == @expected
      end

      it "prefers openstack_password over openstack_api_key" do
        Chef::Config[:knife][:openstack_api_key] = "unexpected"
        expect(auth_params[:openstack_api_key]).to be == @expected
      end
    end

    it "uses openstack_api_key if openstack_password is not set" do
      @expected = "password"
      Chef::Config[:knife][:openstack_api_key] = @expected
      expect(auth_params[:openstack_api_key]).to be == @expected
    end
  end
end
