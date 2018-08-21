# frozen_string_literal: true
#
# Author:: Ameya Varade (<ameya.varade@clogeny.com>)
# Copyright:: Copyright 2013-2018 Chef Software, Inc.
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

require "spec_helper"
require "chef/knife/openstack_server_show"
require "chef/knife/cloud/openstack_service"
require "support/shared_examples_for_command"

describe Chef::Knife::Cloud::OpenstackServerShow do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackServerShow.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackServerShow.new

  let (:instance) { Chef::Knife::Cloud::OpenstackServerShow.new }

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
