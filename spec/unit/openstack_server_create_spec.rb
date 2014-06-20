#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013-2014 Chef Software, Inc.

require File.expand_path('../../spec_helper', __FILE__)
require 'fog'
require 'chef/knife/bootstrap'
require 'chef/knife/bootstrap_windows_winrm'

describe Chef::Knife::OpenstackServerCreate do
  before do

    @openstack_connection = double(Fog::Compute::OpenStack)
    allow(@openstack_connection).to receive_message_chain(:flavors, :find).and_return double('flavor', {:id => 'flavor_id'})
    allow(@openstack_connection).to receive_message_chain(:images, :find).and_return double('image', {:id => 'image_id'})
    allow(@openstack_connection).to receive_message_chain(:addresses).and_return [double('addresses', {
          :instance_id => nil,
          :ip => '111.111.111.111',
          :fixed_ip => true
        })]

    @knife_openstack_create = Chef::Knife::OpenstackServerCreate.new
    @knife_openstack_create.initial_sleep_delay = 0
    allow(@knife_openstack_create).to receive(:tcp_test_ssh).and_return(true)
    allow(@knife_openstack_create).to receive(:tcp_test_winrm).and_return(true)

    {
      :image => 'image',
      :openstack_username => 'openstack_username',
      :openstack_password => 'openstack_password',
      :openstack_auth_url => 'openstack_auth_url',
      :server_create_timeout => 1000
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    %w{msg_pair puts print}.each do |method|
      allow(@knife_openstack_create).to receive(method.to_sym)
    end

    @openstack_servers = double()
    @new_openstack_server = double()

    @openstack_server_attribs = { :name => 'Mock Server',
      :id => 'id-123456',
      :key_name => 'key_name',
      :flavor => 'flavor_id',
      :image => 'image_id',
      :availability_zone => 'zone1',
      :addresses => {
        'foo' => [{'addr' => '34.56.78.90'}],
        'public' => [{'addr' => '75.101.253.10'}],
        'private' => [{'addr' => '10.251.75.20'}]
      },
      :password => 'password'
    }

    @openstack_server_attribs.each_pair do |attrib, value|
      allow(@new_openstack_server).to receive(attrib).and_return(value)
    end
  end

  describe "options" do
    before do
      @options = @knife_openstack_create.options
    end

    it "ensures default options" do
      expect(@options[:bootstrap_protocol][:default]).to be_nil
      expect(@options[:bootstrap_protocol][:default]).to be_nil
      expect(@options[:distro][:default]).to eq('chef-full')
      expect(@options[:availability_zone][:default]).to be_nil
      expect(@options[:metadata][:default]).to be_nil
      expect(@options[:floating_ip][:default]).to eq('-1')
      expect(@options[:host_key_verify][:default]).to be true
      expect(@options[:private_network][:default]).to be false
      expect(@options[:network][:default]).to be true
      expect(@options[:bootstrap_network][:default]).to eq('public')
      expect(@options[:run_list][:default]).to eq([])
      expect(@options[:security_groups][:default]).to eq(['default'])
      expect(@options[:server_create_timeout][:default]).to eq(600)
      expect(@options[:ssh_port][:default]).to eq('22')
      expect(@options[:ssh_user][:default]).to eq('root')
      expect(@options[:first_boot_attributes][:default]).to eq({})
    end

    it "doesn't set an OpenStack endpoint type by default" do
      expect(Chef::Config[:knife][:openstack_endpoint_type]).to be_nil
    end

    it "user_data should be empty" do
      expect(Chef::Config[:knife][:user_data]).to be_nil
    end
  end

  describe "run" do
    before do
      expect(@openstack_servers).to receive(:create).and_return(@new_openstack_server)
      expect(@openstack_connection).to receive(:servers).and_return(@openstack_servers)
      expect(Fog::Compute::OpenStack).to receive(:new).and_return(@openstack_connection)
      @bootstrap = Chef::Knife::Bootstrap.new
      allow(Chef::Knife::Bootstrap).to receive(:new).and_return(@bootstrap)
      expect(@bootstrap).to receive(:run)
      @knife_openstack_create.config[:run_list] = []
      @knife_openstack_create.config[:floating_ip] = '-1'
    end

    after do
      Chef::Config[:knife].delete(:bootstrap_protocol)
    end

    describe "when configuring the bootstrap process with no network when public and private address are nil" do
      before do
        @knife_openstack_create.config[:network] = false
        @openstack_server_attribs[:addresses]["public"][0]["addr"] = nil
        @openstack_server_attribs[:addresses]["private"][0]["addr"] = nil
        expect(@new_openstack_server).to receive(:wait_for).and_return(true)
      end
      after do
        @openstack_server_attribs[:addresses]["public"][0]["addr"] = '75.101.253.10'
        @openstack_server_attribs[:addresses]["private"][0]["addr"] = '10.251.75.20'
      end

      it "uses the ip provided by server.addresses" do
        expect(@knife_openstack_create).to receive(:bootstrap_for_node).with(@new_openstack_server,"34.56.78.90").and_return(@bootstrap)
        @knife_openstack_create.run
      end
    end

    it "Creates an OpenStack instance and bootstraps it" do
      expect(@new_openstack_server).to receive(:wait_for).and_return(true)
      @knife_openstack_create.run
    end

    it "Creates an OpenStack instance for Windows and bootstraps it" do
      @bootstrap_win = Chef::Knife::BootstrapWindowsWinrm.new
      allow(Chef::Knife::BootstrapWindowsWinrm).to receive(:new).and_return(@bootstrap_win)
      Chef::Config[:knife][:bootstrap_protocol] = 'winrm'
      expect(@new_openstack_server).to receive(:wait_for).and_return(true)
      @knife_openstack_create.run
    end

    it "creates an OpenStack instance, assigns existing floating ip and bootstraps it" do
      @knife_openstack_create.config[:floating_ip] = "111.111.111.111"
      expect(@new_openstack_server).to receive(:wait_for).and_return(true)
      expect(@new_openstack_server).to receive(:associate_address).with('111.111.111.111')
      @knife_openstack_create.run
    end
  end

  describe "when configuring the bootstrap process" do
    before do
      @knife_openstack_create.config[:ssh_user] = "ubuntu"
      @knife_openstack_create.config[:ssh_port] = "44"
      @knife_openstack_create.config[:identity_file] = "~/.ssh/key.pem"
      @knife_openstack_create.config[:chef_node_name] = "blarf"
      @knife_openstack_create.config[:template_file] = '~/.chef/templates/my-bootstrap.sh.erb'
      @knife_openstack_create.config[:distro] = 'ubuntu-10.04-magic-sparkles'
      @knife_openstack_create.config[:first_boot_attributes] = {'some_var' => true}
      @knife_openstack_create.config[:run_list] = ['role[base]']

      @bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
    end

    it "should set the bootstrap 'name argument' to the hostname of the OpenStack server" do
      expect(@bootstrap.name_args).to eq(['75.101.253.10'])
    end

    it "configures sets the bootstrap's run_list" do
      expect(@bootstrap.config[:run_list]).to eq(['role[base]'])
    end

    it "configures the bootstrap to use the correct ssh_user login" do
      expect(@bootstrap.config[:ssh_user]).to eq('ubuntu')
    end

    it "configures the bootstrap to use the correct ssh_port" do
      expect(@bootstrap.config[:ssh_port]).to eq('44')
    end

    it "configures the bootstrap to use the correct ssh identity file" do
      expect(@bootstrap.config[:identity_file]).to eq("~/.ssh/key.pem")
    end

    it "configures the bootstrap to use the configured node name if provided" do
      expect(@bootstrap.config[:chef_node_name]).to eq('blarf')
    end

    it "configures the bootstrap to use the server password" do
      expect(@bootstrap.config[:ssh_password]).to eq('password')
    end

    it "configures the bootstrap to use the config ssh password" do
      @knife_openstack_create.config[:ssh_password] = 'testing123'

      bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])

      expect(bootstrap.config[:ssh_password]).to eq('testing123')
    end

    it "configures the bootstrap to use the OpenStack server id if no explicit node name is set" do
      @knife_openstack_create.config[:chef_node_name] = nil

      bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
      expect(bootstrap.config[:chef_node_name]).to eq(@new_openstack_server.name)
    end

    it "configures the bootstrap to use prerelease versions of chef if specified" do
      expect(@bootstrap.config[:prerelease]).to be_nil

      @knife_openstack_create.config[:prerelease] = true

      bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
      expect(bootstrap.config[:prerelease]).to be true
    end

    it "configures the bootstrap to use the desired distro-specific bootstrap script" do
      expect(@bootstrap.config[:distro]).to eq('ubuntu-10.04-magic-sparkles')
    end

    it "configures the bootstrap to use sudo" do
      expect(@bootstrap.config[:use_sudo]).to be true
    end

    it "configures the bootstrap with json attributes" do
      expect(@bootstrap.config[:first_boot_attributes]['some_var']).to be true
    end

    it "configured the bootstrap to use the desired template" do
      expect(@bootstrap.config[:template_file]).to eq('~/.chef/templates/my-bootstrap.sh.erb')
    end

    it "configured the bootstrap to set an openstack hint (via Chef::Config)" do
      expect(Chef::Config[:knife][:hints]['openstack']).to_not be_nil
    end
  end

  describe "when configuring the bootstrap process with private networks" do
    before do
      @knife_openstack_create.config[:private_network] = true

      @bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['private'].last['addr'])
    end

    it "configures the bootstrap to use private network" do
      expect(@bootstrap.name_args).to eq(['10.251.75.20'])
    end
  end

  describe "when configuring the bootstrap process with alternate networks" do
    before do
      @knife_openstack_create.config[:bootstrap_network] = 'foo'

      @bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['foo'].last['addr'])
    end

    it "configures the bootstrap to use alternate network" do
      expect(@bootstrap.name_args).to eq(['34.56.78.90'])
    end
  end

  describe "when configuring the bootstrap process with no networks" do
    before do
      @knife_openstack_create.config[:network] = false

      @bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
    end

    it "configures the bootstrap to use public network since none specified" do
      expect(@bootstrap.name_args).to eq(['75.101.253.10'])
    end
  end

end
