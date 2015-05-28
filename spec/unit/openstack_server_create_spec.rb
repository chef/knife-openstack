#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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


require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/openstack_server_create'
require 'support/shared_examples_for_servercreatecommand'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackServerCreate do
  create_instance = Chef::Knife::Cloud::OpenstackServerCreate.new
  create_instance.define_singleton_method(:post_connection_validations){}

  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerCreate.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, create_instance

  describe "#create_service_instance" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
    end

    it "return OpenstackService instance" do
      expect(@instance.create_service_instance).to be_an_instance_of(Chef::Knife::Cloud::OpenstackService)
    end

    it "has custom_arguments as its option" do
      expect(@instance.options.include? :custom_attributes).to be true
     end
  end

  describe "#validate_params!" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      allow(@instance.ui).to receive(:error)
      Chef::Config[:knife][:bootstrap_protocol] = "ssh"
      Chef::Config[:knife][:identity_file] = "identity_file"
      Chef::Config[:knife][:image_os_type] = "linux"
      Chef::Config[:knife][:openstack_ssh_key_id] = "openstack_ssh_key"
      Chef::Config[:knife][:openstack_region] = "test-region"
    end

    after(:all) do
      Chef::Config[:knife].delete(:bootstrap_protocol)
      Chef::Config[:knife].delete(:identity_file)
      Chef::Config[:knife].delete(:image_os_type)
      Chef::Config[:knife].delete(:openstack_ssh_key_id)
      Chef::Config[:knife].delete(:openstack_region)
    end

    it "run sucessfully on all params exist" do
      expect { @instance.validate_params! }.to_not raise_error
    end
  end

  describe "#before_exec_command" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      allow(@instance.ui).to receive(:error)
      @instance.config[:chef_node_name] = "chef_node_name"
      Chef::Config[:knife][:image] = "image"
      Chef::Config[:knife][:flavor] = "flavor"
      Chef::Config[:knife][:openstack_security_groups] = "openstack_security_groups"
      Chef::Config[:knife][:server_create_timeout] = "server_create_timeout"
      Chef::Config[:knife][:openstack_ssh_key_id] = "openstack_ssh_key"
      Chef::Config[:knife][:network_ids] = "test_network_id"
      allow(Chef::Config[:knife][:network_ids]).to receive(:map).and_return(Chef::Config[:knife][:network_ids])
      Chef::Config[:knife][:metadata] = "foo=bar"
    end

    after(:all) do
      Chef::Config[:knife].delete(:image)
      Chef::Config[:knife].delete(:flavor)
      Chef::Config[:knife].delete(:openstack_ssh_key_id)
      Chef::Config[:knife].delete(:openstack_security_groups)
      Chef::Config[:knife].delete(:server_create_timeout)
      Chef::Config[:knife].delete(:metadata)
    end

    it "set create_options" do
      @instance.service = double
      allow(@instance.service).to receive(:get_image).and_return(get_mock_resource('image'))
      allow(@instance.service).to receive(:get_flavor).and_return(get_mock_resource('flavor'))
      expect(@instance.service).to receive(:create_server_dependencies)
      expect(@instance).to receive(:post_connection_validations)
      @instance.before_exec_command
      expect(@instance.create_options[:server_def][:name]).to be == @instance.config[:chef_node_name]
      expect(@instance.create_options[:server_def][:image_ref]).to be == Chef::Config[:knife][:image]
      expect(@instance.create_options[:server_def][:security_groups]).to be == Chef::Config[:knife][:openstack_security_groups]
      expect(@instance.create_options[:server_def][:flavor_ref]).to be == Chef::Config[:knife][:flavor]
      expect(@instance.create_options[:server_def][:nics]).to be == Chef::Config[:knife][:network_ids]
      expect(@instance.create_options[:server_def][:metadata]).to be == Chef::Config[:knife][:metadata]
      expect(@instance.create_options[:server_def][:region]).to be == Chef::Config[:knife][:openstack_region]
      expect(@instance.create_options[:server_create_timeout]).to be == Chef::Config[:knife][:server_create_timeout]
    end

    it "doesn't set user data in server_def if user_data not specified" do
      @instance.service = double("Chef::Knife::Cloud::OpenstackService", :create_server_dependencies => nil)
      allow(@instance.service).to receive(:get_image).and_return(get_mock_resource('image'))
      allow(@instance.service).to receive(:get_flavor).and_return(get_mock_resource('flavor'))
      expect(@instance).to receive(:post_connection_validations)
      @instance.before_exec_command
      expect(@instance.create_options[:server_def]).to_not include(:user_data)
    end

    it "sets user data" do
      user_data = "echo 'hello world' >> /tmp/user_data.txt"
      Chef::Config[:knife][:user_data] = user_data
      @instance.service = double("Chef::Knife::Cloud::OpenstackService", :create_server_dependencies => nil)
      allow(@instance.service).to receive(:get_image).and_return(get_mock_resource('image'))
      allow(@instance.service).to receive(:get_flavor).and_return(get_mock_resource('flavor'))
      expect(@instance).to receive(:post_connection_validations)
      @instance.before_exec_command
      expect(@instance.create_options[:server_def][:user_data]).to be == user_data
    end

    context "with multiple network_ids specified" do
      before(:each) do
        @instance.service = double
        allow(@instance.service).to receive(:get_image).and_return(get_mock_resource('image'))
        allow(@instance.service).to receive(:get_flavor).and_return(get_mock_resource('flavor'))
        expect(@instance.service).to receive(:create_server_dependencies)
        Chef::Config[:knife][:network_ids] = "test_network_id1,test_network_id2"
        allow(Chef::Config[:knife][:network_ids]).to receive(:map).and_return(Chef::Config[:knife][:network_ids].split(","))
        expect(@instance).to receive(:post_connection_validations)
      end

      it "creates the server_def with multiple nic_ids." do
        @instance.before_exec_command
        expect(@instance.create_options[:server_def][:nics]).to be == ["test_network_id1", "test_network_id2"]
      end
    end

    it "ensures default value for metadata" do
      options = @instance.options
      expect(options[:metadata][:default]).to be == nil
    end
  end

  describe "#after_exec_command" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      allow(@instance).to receive(:msg_pair)
    end

    after(:all) do
      Chef::Config[:knife].delete(:openstack_floating_ip)
    end

    it "don't set openstack_floating_ip on missing openstack_floating_ip option" do
      #default openstack_floating_ip is '-1'
      Chef::Config[:knife][:openstack_floating_ip] = "-1"
      @instance.service = Chef::Knife::Cloud::Service.new
      @instance.server = double
      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.1.1"}]})
      expect(@instance).to receive(:bootstrap)
      @instance.after_exec_command
    end

    it "set openstack_floating_ip on openstack_floating_ip option" do
      Chef::Config[:knife][:openstack_floating_ip] = nil
      @instance.service = Chef::Knife::Cloud::Service.new
      @instance.server = double

      @network = double
      @ports = ['id' => 'test',
                'fixed_ips' => ['ip_address' => '127.0.1.1']]
      allow(@network).to receive(:list_ports).and_return(body: {'ports' => @ports})
      @floating_ips = ['id' => 'test',
                'fixed_ips' => ['ip_address' => '127.0.1.1']]
      allow(@network).to receive(:list_floating_ips).and_return(body: {'floatingips' => @floating_ips})
      allow(@network).to receive(:associate_floating_ip)
      allow(@instance.service).to receive(:network).and_return(@network)

      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.1.1"}]})
      expect(@instance).to receive(:bootstrap)
      allow(@instance.service).to receive(:connection).and_return(double)
      free_floating = Object.new
      free_floating.define_singleton_method(:fixed_ip) { return nil }
      free_floating.define_singleton_method(:ip) { return "127.0.0.1" }
      expect(@instance.service.connection).to receive(:addresses).and_return([free_floating])
      @instance.after_exec_command
    end

    it "raise error on unavailability of free_floating ip" do
      Chef::Config[:knife][:openstack_floating_ip] = nil
      @instance.service = Chef::Knife::Cloud::Service.new
      allow(@instance.ui).to receive(:fatal)
      @instance.server = double
      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.1.1"}]})
      expect(@instance).to_not receive(:bootstrap)
      allow(@instance.service).to receive(:connection).and_return(double)
      free_floating = Object.new
      free_floating.define_singleton_method(:fixed_ip) { return "127.0.0.1" }
      expect(@instance.service.connection).to receive(:addresses).and_return([free_floating])
      expect { @instance.after_exec_command }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerSetupError, "Unable to assign a Floating IP from allocated IPs.")
    end
  end

  describe "#before_bootstrap" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.server = double
      # default bootstrap_network is public
      @instance.config[:bootstrap_network] = "public"
      # default no network is true
      @instance.config[:network] = true
      Chef::Config[:knife][:ssh_password] = "config_ssh_password"
    end

    after(:each) do
      Chef::Config[:knife].delete(:ssh_password)
    end

    context "when no-network option specified" do
      before(:each) { @instance.config[:network] = false }

      it "set public ip as a bootstrap ip if both public and private ip available" do
        allow(@instance.server).to receive(:addresses).and_return({"private"=>[{"version"=>4, "addr"=>"127.0.0.1"}], "public"=>[{"version"=>4, "addr"=>"127.0.0.2"}]})
        @instance.before_bootstrap
        expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.2"
      end

      it "set private-ip as a bootstrap ip if private ip is available" do
        allow(@instance.server).to receive(:addresses).and_return({"private"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
        @instance.before_bootstrap
        expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.1"
      end

      it "set available ip as a bootstrap ip if no public, private ip available" do
        allow(@instance.server).to receive(:addresses).and_return({1=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
        @instance.before_bootstrap
        expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.1"
      end
    end

    it "set bootstrap_ip" do
      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      @instance.before_bootstrap
      expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.1"
    end

    it "set private-ip as a bootstrap-ip if private-network option set" do
      allow(@instance.server).to receive(:addresses).and_return({"private"=>[{"version"=>4, "addr"=>"127.0.0.1"}], "public"=>[{"version"=>4, "addr"=>"127.0.0.2"}]})
      @instance.config[:private_network] = true
      @instance.before_bootstrap
      expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.1"
    end

    it "raise error on nil bootstrap_ip" do
      allow(@instance.ui).to receive(:error)

      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>nil}]})
      expect { @instance.before_bootstrap }.to raise_error(Chef::Knife::Cloud::CloudExceptions::BootstrapError, "No IP address available for bootstrapping.")
    end

    it "set public ip as default bootstrap network is public" do
      allow(@instance.server).to receive(:addresses).and_return({"private"=>[{"version"=>4, "addr"=>"127.0.0.1"}], "public"=>[{"version"=>4, "addr"=>"127.0.0.2"}]})
      @instance.before_bootstrap
      expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.2"
    end

    it "configures the bootstrap to use alternate network" do
      allow(@instance.server).to receive(:addresses).and_return({"foo"=>[{"version"=>1, "addr"=>"127.0.0.1"}], "private"=>[{"version"=>4, "addr"=>"127.0.0.2"}], "public"=>[{"version"=>4, "addr"=>"127.0.0.3"}]})
      @instance.config[:bootstrap_network] = 'foo'
      @instance.before_bootstrap
      expect(@instance.config[:bootstrap_ip_address]).to be == "127.0.0.1"
    end

    it "configures the bootstrap to use the server password" do
      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      Chef::Config[:knife].delete(:ssh_password)
      server_password  = "adFRjk1089"
      allow(@instance.server).to receive(:password).and_return(server_password)
      @instance.before_bootstrap
      expect(@instance.config[:ssh_password]).to be == server_password
    end

    it "configures the bootstrap to use the config ssh password" do
      allow(@instance.server).to receive(:addresses).and_return({"public"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      server_password  = "config_ssh_password"
      Chef::Config[:knife][:ssh_password] = server_password
      expect(@instance.server).to_not receive(:password)
      @instance.before_bootstrap
      expect(@instance.config[:ssh_password]).to be == server_password
    end

    it "configures the default private bootstrap network to use 'private'" do
      allow(@instance.server).to receive(:addresses).and_return({"private"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      @instance.config[:private_network] = true
      @instance.before_bootstrap
      expect(@instance.config[:bootstrap_network]).to be == 'private'
    end

    it "configures the bootstrap to use alternate private network" do
      allow(@instance.server).to receive(:addresses).and_return({"secure"=>[{"version"=>4, "addr"=>"127.0.0.1"}]})
      @instance.config[:bootstrap_network] = 'secure'
      @instance.config[:private_network] = true
      @instance.before_bootstrap
      expect(@instance.config[:bootstrap_network]).to be == 'secure'
    end
  end

  describe "#post_connection_validations" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      allow(@instance.ui).to receive(:error)
    end

    it "raise error on invalid image" do
      allow(@instance).to receive(:is_flavor_valid?).and_return(true)
      allow(@instance).to receive(:is_floating_ip_valid?).and_return(true)
      expect(@instance).to receive(:is_image_valid?).and_return(false)
      expect { @instance.post_connection_validations }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You have not provided a valid image ID. Please note the options for this value are -I or --image..")
    end

    it "raise error on invalid flavor" do
      allow(@instance).to receive(:is_image_valid?).and_return(true)
      allow(@instance).to receive(:is_floating_ip_valid?).and_return(true)
      expect(@instance).to receive(:is_flavor_valid?).and_return(false)
      expect { @instance.post_connection_validations }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You have not provided a valid flavor ID. Please note the options for this value are -f or --flavor..")
    end

    it "raise error on invalid floating IP" do
      allow(@instance).to receive(:is_flavor_valid?).and_return(true)
      allow(@instance).to receive(:is_image_valid?).and_return(true)
      expect(@instance).to receive(:is_floating_ip_valid?).and_return(false)
      expect { @instance.post_connection_validations }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You have either requested an invalid floating IP address or none are available..")
    end
  end

  describe "#is_floating_ip_valid?" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      # Default value
      Chef::Config[:knife][:openstack_floating_ip] = "-1"
      @instance.service = double
    end

    after(:all) do
      Chef::Config[:knife].delete(:openstack_floating_ip)
    end

    it "returns true for default" do
      expect(@instance.is_floating_ip_valid?).to be true
    end

    it "returns false if no floating IPs" do
      Chef::Config[:knife].delete(:openstack_floating_ip)
      expect(@instance.service).to receive_message_chain(:connection, :addresses).and_return([])
      expect(@instance.is_floating_ip_valid?).to be false
    end

    context "when floating ip requested without value" do
      it "returns true if fixed_ip is nil" do
        Chef::Config[:knife][:openstack_floating_ip] = nil
        obj = Object.new
        obj.define_singleton_method(:fixed_ip){nil}
        expect(@instance.service).to receive_message_chain(:connection, :addresses).and_return([obj])
        expect(@instance.is_floating_ip_valid?).to be true
      end
    end

    context "when floating ip requested with value" do
      before {Chef::Config[:knife][:openstack_floating_ip] = "127.0.0.1"}
      after {Chef::Config[:knife].delete(:openstack_floating_ip)}

      it "returns true if requested floating IP is exist" do
        obj = Object.new
        obj.define_singleton_method(:ip){return "127.0.0.1"}
        expect(@instance.service).to receive_message_chain(:connection, :addresses).and_return([obj])
        expect(@instance.is_floating_ip_valid?).to be true
      end

      it "returns false if requested floating IP does not exist" do
        obj = Object.new
        obj.define_singleton_method(:ip){return "127.0.1.1"}
        expect(@instance.service).to receive_message_chain(:connection, :addresses).and_return([obj])
        expect(@instance.is_floating_ip_valid?).to be false
      end
    end
  end

  describe "#is_image_valid?" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.service = double
      Chef::Config[:knife][:image] = "image_id"
    end

    after(:each) do
      Chef::Config[:knife].delete(:image)
    end

    it "returns false on invalid image" do
      expect(@instance.service).to receive_message_chain(:get_image).and_return(nil)
      expect(@instance.is_image_valid?).to be false
    end

    it "returns true on valid image" do
      expect(@instance.service).to receive_message_chain(:get_image).and_return("image")
      expect(@instance.is_image_valid?).to be true
    end
  end

  describe "#is_flavor_valid?" do
    before(:each) do
      @instance = Chef::Knife::Cloud::OpenstackServerCreate.new
      @instance.service = double
      Chef::Config[:knife][:flavor] = "flavor"
    end

    after(:each) do
      Chef::Config[:knife].delete(:flavor)
    end

    it "returns false on invalid flavor" do
      expect(@instance.service).to receive_message_chain(:get_flavor).and_return(nil)
      expect(@instance.is_flavor_valid?).to be false
    end

    it "returns true on valid flavor" do
      expect(@instance.service).to receive_message_chain(:get_flavor).and_return("flavor")
      expect(@instance.is_flavor_valid?).to be true
    end
  end
end
