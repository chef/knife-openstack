#
# Author:: Florin STAN (<florin.stan@gmail.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/openstack_base'

class Chef
  class Knife
    class OpenstackNetworkList < Knife
      include Knife::OpenstackBase

      banner "knife openstack network list (options)"

      def run
        validate!
        network_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Status', :bold),
          ui.color('Type', :bold),
          ui.color('Phy Net', :bold),
          ui.color('Seg ID', :bold),
          ui.color('Router Ext', :bold)
        ]

        c = connection('Network')

        begin
          c.networks.sort_by(&:name).each do |n|
            network_list << n.id
            network_list << n.name
            network_list << n.status
            network_list << n.provider_network_type.to_s
            network_list << n.provider_physical_network.to_s
            network_list << n.provider_segmentation_id.to_s
            network_list << n.router_external.to_s
          end
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
        puts ui.list(network_list, :uneven_columns_across, 7)
      end
    end
  end
end

