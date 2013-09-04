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

require 'chef/knife/cloud/server/list_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/cloud/server/list_options'

class Chef
  class Knife
    class Cloud
      class OpenstackServerList < ServerListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions
        include ServerListOptions

        banner "knife openstack server list (options)"

        def before_exec_command
          #set columns_with_info map
          @columns_with_info = [
          {:label => 'Instance ID', :key => 'id'},
          {:label => 'Name', :key => 'name'},
          {:label => 'Public IP', :key => 'addresses', :value_callback => method(:get_public_ip_address)},
          {:label => 'Private IP', :key => 'addresses', :value_callback => method(:get_private_ip_address)},
          {:label => 'Flavor', :key => 'flavor', :value_callback => method(:get_id)},
          {:label => 'Image', :key => 'image', :value_callback => method(:get_id)},
          {:label => 'Keypair', :key => 'key_name'},
          {:label => 'State', :key => 'state'}
        ]
          super
        end

        def get_public_ip_address (addresses)
          primary_public_ip_address(addresses)
        end

        def get_private_ip_address (addresses)
          primary_private_ip_address(addresses)
        end

        def get_id(value)
          value['id']
        end

      end
    end
  end
end
