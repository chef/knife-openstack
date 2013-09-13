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
  end
end
