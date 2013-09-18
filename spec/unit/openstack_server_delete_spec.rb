require 'spec_helper'
require 'chef/knife/openstack_server_delete'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_serverdeletecommand'

describe Chef::Knife::Cloud::OpenstackServerDelete do
  it_behaves_like Chef::Knife::Cloud::ServerDeleteCommand, Chef::Knife::Cloud::OpenstackServerDelete.new

  let (:instance) {Chef::Knife::Cloud::OpenstackServerDelete.new}

  before(:each) do
    instance.stub(:exit)
  end

  describe "#validate!" do
    before(:each) do
      Chef::Config[:knife][:openstack_username] = "testuser"
      Chef::Config[:knife][:openstack_password] = "testpassword"
      Chef::Config[:knife][:openstack_auth_url] = "tsturl"
    end

    it "validate openstack mandatory options" do
      expect {instance.validate!}.to_not raise_error
    end

    it "raise error on openstack_username missing" do
      Chef::Config[:knife].delete(:openstack_username)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Username' value.")
      expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end

    it "raise error on openstack_password missing" do
      Chef::Config[:knife].delete(:openstack_password)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Password' value.")
      expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end

    it "raise error on openstack_auth_url missing" do
      Chef::Config[:knife].delete(:openstack_auth_url)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Auth Url' value.")
      expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end
  end

  describe "#create_service_instance" do
    it "return OpenstackService instance" do
      expect(instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end
  end
end
