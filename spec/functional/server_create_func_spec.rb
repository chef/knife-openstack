#
#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Author:: Lance Albertson (<lance@osuosl.org>)
# Copyright:: Copyright 2013-2020 Chef Software, Inc.
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

require File.expand_path("../../spec_helper", __FILE__)

describe Chef::Knife::Cloud::OpenstackServerCreate do
  before do
    @knife_openstack_create = Chef::Knife::Cloud::OpenstackServerCreate.new
    {
      image: "image",
      openstack_username: "openstack_username",
      openstack_password: "openstack_password",
      openstack_auth_url: "openstack_auth_url",
      server_create_timeout: 1000,
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    @openstack_service = Chef::Knife::Cloud::OpenstackService.new
    allow(@openstack_service).to receive(:msg_pair)
    allow(@openstack_service).to receive(:print)
    image = Object.new
    allow(image).to receive(:id).and_return("image_id")
    allow(@openstack_service).to receive(:get_image).and_return(image)
    flavor = Object.new
    allow(flavor).to receive(:id).and_return("flavor_id")
    allow(@openstack_service).to receive(:get_flavor).and_return(flavor)

    allow(@knife_openstack_create).to receive(:create_service_instance).and_return(@openstack_service)
    allow(@knife_openstack_create).to receive(:puts)
    @new_openstack_server = double

    @openstack_server_attribs = { name: "Mock Server",
                                  id: "id-123456",
                                  key_name: "key_name",
                                  flavor: "flavor_id",
                                  image: "image_id",
                                  addresses: {
                                    "public" => [{ "addr" => "75.101.253.10" }],
                                    "private" => [{ "addr" => "10.251.75.20" }],
                                  },
                                  password: "password",
                                }

    @openstack_server_attribs.each_pair do |attrib, value|
      allow(@new_openstack_server).to receive(attrib).and_return(value)
    end
  end

  describe "run" do
    before(:each) do
      allow(@knife_openstack_create).to receive(:validate_params!)
      allow(Fog::OpenStack::Compute).to receive_message_chain(:new, :servers, :create).and_return(@new_openstack_server)
      @knife_openstack_create.config[:openstack_floating_ip] = "-1"
      allow(@new_openstack_server).to receive(:wait_for)
    end

    context "for Linux" do
      before do
        @config = { openstack_floating_ip: "-1", bootstrap_ip_address: "75.101.253.10", ssh_password: "password", hints: { "openstack" => {} }, distro: "chef-full" }
        @knife_openstack_create.config[:distro] = "chef-full"
        @bootstrapper = Chef::Knife::Cloud::Bootstrapper.new(@config)
        @ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
        @bootstrapdistribution = Chef::Knife::Cloud::BootstrapDistribution.new(@config)
        allow(@ssh_bootstrap_protocol).to receive(:send_bootstrap_command)
      end

      it "Creates an OpenStack instance and bootstraps it" do
        expect(Chef::Knife::Cloud::Bootstrapper).to receive(:new).with(@config).and_return(@bootstrapper)
        allow(@bootstrapper).to receive(:bootstrap).and_call_original
        expect(@bootstrapper).to receive(:create_bootstrap_protocol).and_return(@ssh_bootstrap_protocol)
        expect(@bootstrapper).to receive(:create_bootstrap_distribution).and_return(@bootstrapdistribution)
        expect(@openstack_service).to receive(:server_summary).exactly(2).times
        @knife_openstack_create.run
      end
    end

    context "for Windows" do
      before do
        @config = { openstack_floating_ip: "-1", image_os_type: "windows", bootstrap_ip_address: "75.101.253.10", bootstrap_protocol: "winrm", ssh_password: "password", hints: { "openstack" => {} }, distro: "windows-chef-client-msi" }
        @knife_openstack_create.config[:image_os_type] = "windows"
        @knife_openstack_create.config[:bootstrap_protocol] = "winrm"
        @knife_openstack_create.config[:distro] = "windows-chef-client-msi"
        @bootstrapper = Chef::Knife::Cloud::Bootstrapper.new(@config)
        @winrm_bootstrap_protocol = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@config)
        @bootstrapdistribution = Chef::Knife::Cloud::BootstrapDistribution.new(@config)
      end
      it "Creates an OpenStack instance for Windows and bootstraps it" do
        expect(Chef::Knife::Cloud::Bootstrapper).to receive(:new).with(@config).and_return(@bootstrapper)
        allow(@bootstrapper).to receive(:bootstrap).and_call_original
        expect(@bootstrapper).to receive(:create_bootstrap_protocol).and_return(@winrm_bootstrap_protocol)
        expect(@bootstrapper).to receive(:create_bootstrap_distribution).and_return(@bootstrapdistribution)
        allow(@winrm_bootstrap_protocol).to receive(:send_bootstrap_command)
        expect(@openstack_service).to receive(:server_summary).exactly(2).times
        @knife_openstack_create.run
      end
    end
  end
end
