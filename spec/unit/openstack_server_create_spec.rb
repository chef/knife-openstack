#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/openstack_server_create'
require 'support/shared_examples_for_servercreatecommand'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackServerCreate do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerCreate.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::OpenstackServerCreate.new

  let (:instance) {Chef::Knife::Cloud::OpenstackServerCreate.new}

  before(:each) do
    instance.stub(:exit)
  end

  describe "#create_service_instance" do
    it "return OpenstackService instance" do
      expect(instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end
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
      instance.validate!
    end

    it "raise error on openstack_password missing" do
      Chef::Config[:knife].delete(:openstack_password)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Password' value.")
      instance.validate!
    end

    it "raise error on openstack_auth_url missing" do
      Chef::Config[:knife].delete(:openstack_auth_url)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Auth Url' value.")
      instance.validate!
    end

    it "validates ssh params" do
      Chef::Config[:knife][:image_os] = "other"
      instance.ui.should_receive(:error).with("You must provide either Identity file or SSH Password.")
      instance.validate_params!
    end
  end
end
