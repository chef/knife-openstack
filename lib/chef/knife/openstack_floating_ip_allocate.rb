#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright 2015-2020 Chef Software, Inc.
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
      class OpenstackFloatingIpAllocate < Command
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner "knife openstack floating_ip allocate (options)"

        option :pool,
          short: "-p POOL",
          long: "--pool POOL",
          description: "Floating IP pool to allocate from.",
          proc: proc { |key| Chef::Config[:knife][:pool] = key }

        def execute_command
          @resource = @service.allocate_address(locate_config_value(:pool))
        end

        def after_exec_command
          @columns_with_info = [{ label: "ID", value: @resource["floating_ip"]["id"].to_s },
                                { label: "Instance ID", value: @resource["floating_ip"]["instance_id"].to_s },
                                { label: "Floating IP", value: @resource["floating_ip"]["ip"].to_s },
                                { label: "Fixed IP", value: @resource["floating_ip"]["fixed_ip"].to_s },
                                { label: "Pool", value: @resource["floating_ip"]["pool"].to_s },
                               ]
          @service.server_summary(nil, @columns_with_info)
        end
      end
    end
  end
end
