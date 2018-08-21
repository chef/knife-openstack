# frozen_string_literal: true
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

require "chef/knife/cloud/list_resource_command"
require "chef/knife/openstack_helpers"
require "chef/knife/cloud/openstack_service_options"

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner "knife openstack floating_ip list (options)"

        def before_exec_command
          # set columns_with_info map
          @columns_with_info = [
            { label: "ID", key: "id" },
            { label: "Instance ID", key: "instance_id" },
            { label: "IP Address", key: "ip" },
            { label: "Fixed IP", key: "fixed_ip" },
            { label: "Floating IP Pool", key: "pool" },
          ]
        end

        def query_resource
          @service.list_addresses
        end
      end
    end
  end
end
