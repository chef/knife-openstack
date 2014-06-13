#
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

require 'spec_helper'
require 'chef/knife/openstack_server_show'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackServerShow do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerShow.new

  let (:instance) {Chef::Knife::Cloud::OpenstackServerShow.new}

  context "#validate!" do
    before(:each) do
      Chef::Config[:knife][:openstack_username] = "testuser"
      Chef::Config[:knife][:openstack_password] = "testpassword"
      Chef::Config[:knife][:openstack_auth_url] = "tsturl"
      allow(instance).to receive(:exit)
    end

    it "validate openstack mandatory options" do
      expect {instance.validate!}.to_not raise_error
    end

    it "raise error on openstack_username missing" do
      Chef::Config[:knife].delete(:openstack_username)
      expect(instance.ui).to receive(:error).with("You did not provide a valid 'Openstack Username' value.")
      expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end

    it "raise error on openstack_password missing" do
      Chef::Config[:knife].delete(:openstack_password)
      expect(instance.ui).to receive(:error).with("You did not provide a valid 'Openstack Password' value.")
      expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end

    it "raise error on openstack_auth_url missing" do
      Chef::Config[:knife].delete(:openstack_auth_url)
      expect(instance.ui).to receive(:error).with("You did not provide a valid 'Openstack Auth Url' value.")
      expect { instance.validate! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end
  end

  context "#validate_params!" do
    before(:each) do
      Chef::Config[:knife][:instance_id] = "instance_id"
    end

    it "raise error on instance_id missing" do
      Chef::Config[:knife].delete(:instance_id)
      expect(instance.ui).to receive(:error).with("You must provide a valid Instance Id")
      expect { instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError)
    end
  end
end
