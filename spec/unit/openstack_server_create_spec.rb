#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path('../../spec_helper', __FILE__)
require 'chef/knife/openstack_server_create'

describe Chef::Knife::OpenstackServerCreate do
  before do
    @app = App.new
    @service = Chef::Knife::Cloud::OpenstackService.new

    @openstack_connection = mock(Fog::Compute::OpenStack)
    @openstack_connection.stub_chain(:flavors, :get).and_return ('flavor_id')
    @openstack_connection.stub_chain(:images, :get).and_return mock('image_id')
    @openstack_connection.stub_chain(:addresses).and_return [mock('addresses', {
            :instance_id => nil,
            :ip => '111.111.111.111',
            :fixed_ip => true
            })]

    @knife_openstack_create = Chef::Knife::OpenstackServerCreate.new
    @knife_openstack_create.stub(:tcp_test_ssh).and_return(true)
    @knife_openstack_create.stub(:tcp_test_winrm).and_return(true)

    {
      :image => 'image',
      :openstack_username => 'openstack_username',
      :openstack_password => 'openstack_password',
      :openstack_auth_url => 'openstack_auth_url',
      :server_create_timeout => 1000
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    @knife_openstack_create.stub(:msg_pair)
    @knife_openstack_create.stub(:puts)
    @knife_openstack_create.stub(:print)


    @openstack_servers = mock()
    @new_openstack_server = mock()

    @openstack_server_attribs = { :name => 'Mock Server',
                                  :id => 'id-123456',
                                  :key_name => 'key_name',
                                  :flavor => 'flavor_id',
                                  :image => 'image_id',
                                  :addresses => {
                                    'public' => [{'addr' => '75.101.253.10'}],
                                    'private' => [{'addr' => '10.251.75.20'}]
                                    },
                                  :password => 'password'
                                }


    @openstack_server_attribs.each_pair do |attrib, value|
      @new_openstack_server.stub(attrib).and_return(value)
    end
  end

  describe "run" do
    before do
      @openstack_servers.should_receive(:create_server_def).and_return(@new_openstack_server)
      @openstack_connection.should_receive(:create).and_return(@openstack_servers)
      Fog::Compute::OpenStack.should_receive(:new).and_return(@openstack_connection)
      @bootstrap = Chef::Knife::Bootstrap.new
      Chef::Knife::Bootstrap.stub(:new).and_return(@bootstrap)
      @bootstrap.should_receive(:run)
      @knife_openstack_create.config[:run_list] = []
      @knife_openstack_create.config[:floating_ip] = '-1'
    end

    it "Creates an OpenStack instance and bootstraps it" do
      @new_openstack_server.should_receive(:wait_for).and_return(true)
      @knife_openstack_create.run
    end

    it "Creates an OpenStack instance for Windows and bootstraps it" do
      @bootstrap_win = Chef::Knife::BootstrapWindowsWinrm.new
      Chef::Knife::BootstrapWindowsWinrm.stub(:new).and_return(@bootstrap_win)
      Chef::Config[:knife][:bootstrap_protocol] = 'winrm'
      @new_openstack_server.should_receive(:wait_for).and_return(true)
      @knife_openstack_create.run
    end

    it "creates an OpenStack instance, assigns existing floating ip and bootstraps it" do
      @knife_openstack_create.config[:floating_ip] = "111.111.111.111"
      @new_openstack_server.should_receive(:wait_for).and_return(true)
      @new_openstack_server.should_receive(:associate_address).with('111.111.111.111')
      @knife_openstack_create.run
    end
  end

  describe "when configuring the bootstrap process" do
    before do
      @knife_openstack_create.config[:ssh_user] = "ubuntu"
      @knife_openstack_create.config[:identity_file] = "~/.ssh/key.pem"
      @knife_openstack_create.config[:chef_node_name] = "blarf"
      @knife_openstack_create.config[:template_file] = '~/.chef/templates/my-bootstrap.sh.erb'
      @knife_openstack_create.config[:distro] = 'ubuntu-10.04-magic-sparkles'
      @knife_openstack_create.config[:run_list] = ['role[base]']

      @bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
    end

    it "should set the bootstrap 'name argument' to the hostname of the OpenStack server" do
      @bootstrap.name_args.should == ['75.101.253.10']
    end

    it "configures sets the bootstrap's run_list" do
      @bootstrap.config[:run_list].should == ['role[base]']
    end

    it "configures the bootstrap to use the correct ssh_user login" do
      @bootstrap.config[:ssh_user].should == 'ubuntu'
    end

    it "configures the bootstrap to use the correct ssh identity file" do
      @bootstrap.config[:identity_file].should == "~/.ssh/key.pem"
    end

    it "configures the bootstrap to use the configured node name if provided" do
      @bootstrap.config[:chef_node_name].should == 'blarf'
    end

    it "configures the bootstrap to use the OpenStack server id if no explicit node name is set" do
      @knife_openstack_create.config[:chef_node_name] = nil

      bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
      bootstrap.config[:chef_node_name].should == @new_openstack_server.name
    end

    it "configures the bootstrap to use prerelease versions of chef if specified" do
      @bootstrap.config[:prerelease].should be_false

      @knife_openstack_create.config[:prerelease] = true

      bootstrap = @knife_openstack_create.bootstrap_for_node(@new_openstack_server,
        @new_openstack_server.addresses['public'].last['addr'])
      bootstrap.config[:prerelease].should be_true
    end

    it "configures the bootstrap to use the desired distro-specific bootstrap script" do
      @bootstrap.config[:distro].should == 'ubuntu-10.04-magic-sparkles'
    end

    it "configures the bootstrap to use sudo" do
      @bootstrap.config[:use_sudo].should be_true
    end

    it "configured the bootstrap to use the desired template" do
      @bootstrap.config[:template_file].should == '~/.chef/templates/my-bootstrap.sh.erb'
    end

    it "configured the bootstrap to set an openstack hint (via Chef::Config)" do
      Chef::Config[:knife][:hints]['openstack'].should_not be_nil
    end
  end

end
