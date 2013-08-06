# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

    it "raise error on openstack_username missing and exit immediately." do
      Chef::Config[:knife].delete(:openstack_username)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Username' value.")
      instance.validate!
    end

    it "raise error on openstack_auth_url missing and exit immediately." do
      Chef::Config[:knife].delete(:openstack_auth_url)
      instance.ui.should_receive(:error).with("You did not provide a valid 'Openstack Auth Url' value.")
      instance.validate!
    end
      
    it "validates ssh params" do
      Chef::Config[:knife][:image_os] = "other"
      Chef::Config[:knife][:bootstrap_protocol] = "ssh"
      instance.ui.should_receive(:error).with("You must provide either Identity file or SSH Password.")
      instance.validate_params!
    end

    context "bootstrap protocol: Ssh " do
      before(:each) do
        Chef::Config[:knife][:bootstrap_protocol] = "ssh"
      end

      it "raise error when neither identity file nor SSH password is provided and exits immediately." do
        Chef::Config[:knife][:identity_file] = nil
        Chef::Config[:knife][:ssh_password] = nil
        instance.ui.should_receive(:error).with("You must provide either Identity file or SSH Password.")
        instance.validate_params!
      end

      it "raise error when Identity file is provided but SSH key is not provided and exits immediately." do
        Chef::Config[:knife][:identity_file] = "identity_file_path"
        Chef::Config[:knife][:openstack_ssh_key_id] = nil
        instance.ui.should_receive(:error).with("You must provide SSH Key.")
        instance.validate_params!
      end

      it "validates gracefully when SSH password is provided." do
        Chef::Config[:knife][:identity_file] = nil
        Chef::Config[:knife][:ssh_password] = "ssh_password"
        instance.validate_params!
      end

       it "validates gracefully when both Identity file and SSH key are provided." do
        Chef::Config[:knife][:identity_file] = "identity_file_path"
        Chef::Config[:knife][:openstack_ssh_key_id] = "ssh_key"
        instance.validate!
      end

      it "when no ssh User is provided , the default value should be 'root'." do
        Chef::Config[:knife][:ssh_password] = "ssh_password"
        instance.configure_chef
        expect(instance.config[:ssh_user]).to eq('root')
        instance.validate!
      end
    end

    context "bootstrap protocol: Winrm " do
      before(:each) do
        instance.configure_chef
        instance.config[:bootstrap_protocol] = 'winrm'
        Chef::Config[:knife][:image_os] = 'windows'
      end

       it "validates gracefully when winrm User and Winrm password are provided." do
        instance.config[:winrm_user] = "winrm_user"
        Chef::Config[:knife][:winrm_password] = "winrm_password"
        instance.validate!
      end

      it "when no winrm User is provided , the default value should be 'Administrator'." do
        Chef::Config[:knife][:winrm_password] = "winrm_password"
        expect(instance.config[:winrm_user]).to eq('Administrator')
        instance.validate!
      end

      it "raise error when winrm password is not provided and exits immediately." do
        Chef::Config[:knife][:winrm_password] = nil
        instance.config[:winrm_password] = nil
        instance.ui.should_receive(:error).with("You must provide Winrm Password.")
        instance.validate_params!
      end
    end
  end
end
