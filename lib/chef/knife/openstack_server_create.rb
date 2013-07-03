#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Matt Ray (<matt@opscode.com>)
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2011-2013 Opscode, Inc.
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

require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_server_create_options'
require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/core/bootstrap_context'
require 'net/ssh/multi'
class Chef
  class Knife
    class OpenstackServerCreate < Knife

      include Knife::OpenstackHelpers
      include Knife::Cloud::OpenstackServerCreateOptions
      include Knife::Cloud::OpenstackServiceOptions

      banner "knife openstack server create (options)"

      def run
          $stdout.sync = true
          @cloud_service = Cloud::OpenstackService.new(self)
          @cloud_service.server_create()
      end
    end
  end
end
