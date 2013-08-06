#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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

describe Chef::Knife::Cloud::OpenstackServerCreate do

  before do
    @knife_openstack_create = Chef::Knife::Cloud::OpenstackServerCreate.new
    {
      :image => 'image',
      :openstack_username => 'openstack_username',
      :openstack_password => 'openstack_password',
      :openstack_auth_url => 'openstack_auth_url',
      :server_create_timeout => 1000
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    @openstack_service = Chef::Knife::Cloud::OpenstackService.new
    @openstack_service.stub(:msg_pair)
    @openstack_service.stub(:print)
    @knife_openstack_create.stub(:create_service_instance).and_return(@openstack_service)
    @knife_openstack_create.stub(:puts)
    @new_openstack_server = double()

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
    before(:each) do
      @knife_openstack_create.stub(:validate_params!)
      Fog::Compute::OpenStack.stub_chain(:new, :servers, :create).and_return(@new_openstack_server)
      @knife_openstack_create.config[:openstack_floating_ip] = '-1'
      @new_openstack_server.stub(:wait_for)
    end

    context "for Linux" do
      before do
        @config = {:openstack_floating_ip=>"-1", :bootstrap_ip_address => "75.101.253.10"}
        @knife_openstack_create.config[:distro] = 'chef-full'
        @bootstrapper = Chef::Knife::Cloud::Bootstrapper.new(@config)
        @ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
        @unix_distribution = Chef::Knife::Cloud::UnixDistribution.new(@config)
        @ssh_bootstrap_protocol.stub(:send_bootstrap_command)
      end

      it "Creates an OpenStack instance and bootstraps it" do
        Chef::Knife::Cloud::Bootstrapper.should_receive(:new).with(@config).and_return(@bootstrapper)
        @bootstrapper.stub(:bootstrap).and_call_original
        @bootstrapper.should_receive(:create_bootstrap_protocol).and_return(@ssh_bootstrap_protocol)
        @bootstrapper.should_receive(:create_bootstrap_distribution).and_return(@unix_distribution)
        @knife_openstack_create.run
      end
    end

    context "for Windows" do
      before do
        @config = {:openstack_floating_ip=>"-1", :image_os_type => 'windows', :bootstrap_ip_address => "75.101.253.10", :bootstrap_protocol => 'winrm'}
        @knife_openstack_create.config[:image_os_type] = 'windows'
        @knife_openstack_create.config[:bootstrap_protocol] = 'winrm'
        @knife_openstack_create.config[:distro] = 'windows-chef-client-msi'
        @bootstrapper = Chef::Knife::Cloud::Bootstrapper.new(@config)
        @winrm_bootstrap_protocol = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@config)
        @windows_distribution = Chef::Knife::Cloud::WindowsDistribution.new(@config)
      end
      it "Creates an OpenStack instance for Windows and bootstraps it" do
        Chef::Knife::Cloud::Bootstrapper.should_receive(:new).with(@config).and_return(@bootstrapper)
        @bootstrapper.stub(:bootstrap).and_call_original
        @bootstrapper.should_receive(:create_bootstrap_protocol).and_return(@winrm_bootstrap_protocol)
        @bootstrapper.should_receive(:create_bootstrap_distribution).and_return(@windows_distribution)
        @winrm_bootstrap_protocol.stub(:send_bootstrap_command)
        @knife_openstack_create.run
      end
    end

  end
end
