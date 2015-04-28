#
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

require 'spec_helper'
require 'chef/knife/openstack_flavor_list'
require 'chef/knife/cloud/openstack_service'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::OpenstackVolumeList do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::OpenstackVolumeList.new

  include_context "#validate!", Chef::Knife::Cloud::OpenstackVolumeList.new
end
