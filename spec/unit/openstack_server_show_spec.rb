require 'spec_helper'
require 'chef/knife/openstack_server_show'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackServerShow do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerShow.new

  let (:instance) {Chef::Knife::Cloud::OpenstackServerShow.new}

  context "#validate!" do
    before(:each) do
      Chef::Config[:knife][:openstack_username] = "testuser"
      Chef::Config[:knife][:openstack_password] = "testpassword"
      Chef::Config[:knife][:openstack_auth_url] = "tsturl"
      instance.stub(:exit)
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

  context "#validate_params!" do
    before(:each) do
      Chef::Config[:knife][:instance_id] = "instance_id"
    end

    it "raise error on instance_id missing" do
      Chef::Config[:knife].delete(:instance_id)
      instance.ui.should_receive(:error).with("You must provide a valid Instance Id")
      expect { instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end
  end
end
