# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/openstack_server_create'
require 'support/shared_examples_for_servercreatecommand'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackServerCreate do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerCreate.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::OpenstackServerCreate.new
  
  describe "#create_service_instance" do
    it "return OpenstackService instance" do
      instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      expect(instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end
  end

  describe "#validate_params!" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.ui.stub(:error)
      Chef::Config[:knife][:bootstrap_protocol] = "ssh"
      Chef::Config[:knife][:identity_file] = "identity_file"
      Chef::Config[:knife][:image_os_type] = "linux"
      Chef::Config[:knife][:openstack_ssh_key_id] = "openstack_ssh_key"
    end

    after(:all) do
      Chef::Config[:knife].delete(:bootstrap_protocol)
      Chef::Config[:knife].delete(:identity_file)
      Chef::Config[:knife].delete(:image_os_type)
      Chef::Config[:knife].delete(:openstack_ssh_key_id)
    end

    it "run sucessfully on all params exist" do
      expect { @instance.validate_params! }.to_not raise_error
    end

    it "raise error if ssh key is missing" do
      Chef::Config[:knife].delete(:openstack_ssh_key_id)
      expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError,  " You must provide SSH Key..")
    end
  end

  describe "#before_exec_command" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.ui.stub(:error)
      @instance.config[:chef_node_name] = "chef_node_name"
      Chef::Config[:knife][:image] = "image"
      Chef::Config[:knife][:flavor] = "flavor"
      Chef::Config[:knife][:openstack_security_groups] = "openstack_security_groups"
      Chef::Config[:knife][:server_create_timeout] = "server_create_timeout"
      Chef::Config[:knife][:openstack_ssh_key_id] = "openstack_ssh_key"
    end

    after(:all) do
      Chef::Config[:knife].delete(:image)
      Chef::Config[:knife].delete(:flavor)
      Chef::Config[:knife].delete(:openstack_ssh_key_id)
      Chef::Config[:knife].delete(:openstack_security_groups)
      Chef::Config[:knife].delete(:server_create_timeout)
    end

    it "set create_options" do
      @instance.service = double
      @instance.service.should_receive(:create_server_dependencies)
      @instance.before_exec_command
      @instance.create_options[:server_def][:name].should == @instance.config[:chef_node_name]
      @instance.create_options[:server_def][:image_ref].should == Chef::Config[:knife][:image]
      @instance.create_options[:server_def][:security_groups].should == Chef::Config[:knife][:openstack_security_groups]
      @instance.create_options[:server_def][:flavor_ref].should == Chef::Config[:knife][:flavor]
      @instance.create_options[:server_create_timeout].should == Chef::Config[:knife][:server_create_timeout]
    end

    it "doesn't set user data in server_def if user_data not specified" do
      @instance.service = double("Chef::Knife::Cloud::OpenstackService", :create_server_dependencies => nil)
      @instance.before_exec_command
      @instance.create_options[:server_def].should_not include(:user_data)
    end

    it "sets user data" do
      user_data = "echo 'hello world' >> /tmp/user_data.txt"
      Chef::Config[:knife][:user_data] = user_data
      @instance.service = double("Chef::Knife::Cloud::OpenstackService", :create_server_dependencies => nil)
      @instance.before_exec_command
      @instance.create_options[:server_def][:user_data].should == user_data
    end
  end

  describe "#after_exec_command" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.stub(:msg_pair)
    end

    after(:all) do
      Chef::Config[:knife].delete(:openstack_floating_ip)
    end

    it "don't set openstack_floating_ip on missing openstack_floating_ip option" do
      #default openstack_floating_ip is '-1'
      Chef::Config[:knife][:openstack_floating_ip] = "-1"
      @instance.service = Chef::Knife::Cloud::Service.new
      @instance.server = double
      @instance.server.should_receive(:flavor).and_return({"id" => "2"})
      @instance.server.should_receive(:image).and_return({"id" => "image_id"})
      @instance.server.should_not_receive(:associate_address)
      @instance.server.stub(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.1.1"}]})
      @instance.should_receive(:bootstrap)
      @instance.after_exec_command
    end

    it "set openstack_floating_ip on openstack_floating_ip option" do
      Chef::Config[:knife][:openstack_floating_ip] = nil
      @instance.service = Chef::Knife::Cloud::Service.new
      @instance.server = double
      @instance.server.should_receive(:flavor).and_return({"id" => "2"})
      @instance.server.should_receive(:image).and_return({"id" => "image_id"})
      @instance.server.stub(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.1.1"}]})
      @instance.should_receive(:bootstrap)
      connection = double
      @instance.service.stub(:connection).and_return(double)
      free_floating = Object.new
      free_floating.define_singleton_method(:fixed_ip) { return nil }
      free_floating.define_singleton_method(:ip) { return "127.0.0.1" }
      @instance.service.connection.should_receive(:addresses).and_return([free_floating])
      @instance.server.should_receive(:associate_address).with(free_floating.ip)
      @instance.after_exec_command
    end

    it "raise error on unavailability of free_floating ip" do
      Chef::Config[:knife][:openstack_floating_ip] = nil
      @instance.service = Chef::Knife::Cloud::Service.new
      @instance.ui.stub(:fatal)
      @instance.server = double
      @instance.server.should_receive(:flavor).and_return({"id" => "2"})
      @instance.server.should_receive(:image).and_return({"id" => "image_id"})
      @instance.server.stub(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.1.1"}]})
      @instance.should_not_receive(:bootstrap)
      connection = double
      @instance.service.stub(:connection).and_return(double)
      free_floating = Object.new
      free_floating.define_singleton_method(:fixed_ip) { return "127.0.0.1" }
      @instance.service.connection.should_receive(:addresses).and_return([free_floating])
      @instance.server.should_not_receive(:associate_address)
      expect { @instance.after_exec_command }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerSetupError, "Unable to assign a Floating IP from allocated IPs.")
    end    
  end

  describe "#before_bootstrap" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.server = double
    end

    it "set bootstrap_ip" do
      @instance.server.stub(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      @instance.before_bootstrap
      @instance.config[:bootstrap_ip_address].should == "127.0.0.1"
    end

    it "set private-ip as a bootstrap-ip if openstack-private-network option set" do
      @instance.server.stub(:addresses).and_return({"private"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      @instance.config[:openstack_private_network] = true
      @instance.before_bootstrap
      @instance.config[:bootstrap_ip_address].should == "127.0.0.1"
    end

    it "raise error on nil bootstrap_ip" do
      @instance.ui.stub(:error)
      @instance.server.stub(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>nil}]})
      expect { @instance.before_bootstrap }.to raise_error(Chef::Knife::Cloud::CloudExceptions::BootstrapError, "No IP address available for bootstrapping.")
    end    
  end
end
