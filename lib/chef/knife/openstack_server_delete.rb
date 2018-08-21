# frozen_string_literal: true
#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
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
#

require "chef/knife/cloud/server/delete_options"
require "chef/knife/cloud/server/delete_command"
require "chef/knife/cloud/openstack_service"
require "chef/knife/cloud/openstack_service_options"
require "chef/knife/openstack_helpers"

class Chef
  class Knife
    class Cloud
      class OpenstackServerDelete < ServerDeleteCommand
        include ServerDeleteOptions
        include OpenstackServiceOptions
        include OpenstackHelpers

        banner "knife openstack server delete INSTANCEID [INSTANCEID] (options)"
      end
    end
  end
end
