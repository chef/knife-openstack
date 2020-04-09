#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Matt Ray (<matt@chef.io>)
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright 2011-2020 Chef Software, Inc.
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

require "chef/knife/cloud/server/list_command"
require_relative "openstack_helpers"
require_relative "cloud/openstack_service_options"
require "chef/knife/cloud/server/list_options"

class Chef
  class Knife
    class Cloud
      class OpenstackServerList < ServerListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions
        include ServerListOptions

        banner "knife openstack server list (options)"

        def before_exec_command
          # set columns_with_info map
          @columns_with_info = [
            { label: "Name", key: "name" },
            { label: "Instance ID", key: "id" },
            { label: "Addresses", key: "addresses", value_callback: method(:addresses) },
            { label: "Flavor", key: "flavor", value_callback: method(:get_id) },
            { label: "Image", key: "image", value_callback: method(:get_id) },
            { label: "Keypair", key: "key_name" },
            { label: "State", key: "state" },
            { label: "Availability Zone", key: "availability_zone" },
          ]
          @sort_by_field = "name"
          super
        end

        def addresses(addresses)
          instance_addresses(addresses)
        end

        def get_id(value)
          value["id"]
        end
      end
    end
  end
end
