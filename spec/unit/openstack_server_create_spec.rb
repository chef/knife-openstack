#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path('../../spec_helper', __FILE__)
require 'fog'
require 'chef/knife/bootstrap'
require 'chef/knife/bootstrap_windows_winrm'

describe Chef::Knife::OpenstackServerCreate do
  before do
    @knife_openstack_create = Chef::Knife::OpenstackServerCreate.new
    @knife_openstack_create.initial_sleep_delay = 0
    @knife_openstack_create.stub!(:tcp_test_ssh).and_return(true)
    @knife_openstack_create.stub!(:tcp_test_winrm).and_return(true)

    {
      :image => 'image',
      :openstack_username => 'openstack_username',
      :openstack_password => 'openstack_password',
      :openstack_auth_url => 'openstack_auth_url',
      :server_create_timeout => 1000
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    @openstack_connection = mock(Fog::Compute::OpenStack)
    @openstack_connection.stub_chain(:flavors, :get).and_return ('flavor_id')
    @openstack_connection.stub_chain(:images, :get).and_return mock('image_id')
        
    @openstack_servers = mock()
    @new_openstack_server = mock()

    @openstack_server_attribs = { :name => 'Mock Server',
                                  :id => 'id-123456',
                                  :key_name => 'key_name',
                                  :public_ip_address => { 'addr' => '75.101.253.10'},
                                  :private_ip_address => '10.251.75.20',
                                  :flavor => 'flavor_id',
                                  :image => 'image_id'
                                }


      @openstack_server_attribs.each_pair do |attrib, value|
        @new_openstack_server.stub!(attrib).and_return(value)
      end
  end

  describe "run" do
    before do
      @openstack_servers.should_receive(:create).and_return(@new_openstack_server)
      @openstack_connection.should_receive(:servers).and_return(@openstack_servers)

      Fog::Compute::OpenStack.should_receive(:new).and_return(@openstack_connection)

      @bootstrap = Chef::Knife::Bootstrap.new
      Chef::Knife::Bootstrap.stub!(:new).and_return(@bootstrap)
      @bootstrap.should_receive(:run)
    end

    it "Creates an OpenStack instance and bootstraps it" do
      @new_openstack_server.should_receive(:wait_for).and_return(true)
      @knife_openstack_create.run
      #@knife_openstack_create.server.should_not == nil
    end

    it "Creates an OpenStack instance for Windows and bootstraps it" do
      Chef::Config[:knife][:bootstrap_protocol] = 'winrm'
      @new_openstack_server.should_receive(:wait_for).and_return(true)
      @knife_openstack_create.run
      #@knife_openstack_create.server.should_not == nil
    end
  end
end