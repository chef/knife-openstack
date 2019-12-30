#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright 2015-2018 Chef Software, Inc.
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

require_relative "openstack_helpers"
require_relative "cloud/openstack_service_options"
require "chef/knife/cloud/command"

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpRelease < Command
        include OpenstackServiceOptions
        include OpenstackHelpers

        banner "knife openstack floating_ip release ID [ID] (options)"

        def execute_command
          if @name_args[0]
            response = service.release_address(@name_args[0])
            if response && response.status == 202
              ui.info "Floating IP released successfully."
            end
          else
            ui.error "Please provide Floating IP to release."
            exit 1
          end
        end
      end
    end
  end
end
