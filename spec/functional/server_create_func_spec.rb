# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
require File.expand_path('../../spec_helper', __FILE__)

describe Chef::Knife::OpenstackServerCreate do

  before do
    @openstack_connection = mock(Fog::Compute::OpenStack)
    @openstack_connection.stub_chain(:flavors, :get).and_return ('flavor_id')
    @openstack_connection.stub_chain(:images, :get).and_return mock('image_id')
    @openstack_connection.stub_chain(:addresses).and_return [mock('addresses', {
            :instance_id => nil,
            :ip => '111.111.111.111',
            :fixed_ip => true
            })]

    @knife_openstack_create = Chef::Knife::OpenstackServerCreate.new
    @knife_openstack_create.initial_sleep_delay = 0
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
      @openstack_servers.should_receive(:create).and_return(@new_openstack_server)
      @openstack_connection.should_receive(:servers).and_return(@openstack_servers)
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
end
