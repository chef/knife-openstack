#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Matt Ray (<matt@opscode.com>)
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

require 'chef/knife/openstack_base'

class Chef
  class Knife
    class OpenstackServerList < Knife

      include Knife::OpenstackBase

      banner "knife openstack server list (options)"

      def run
        $stdout.sync = true

        validate!

        server_list = [
          ui.color('Instance ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('Keypair', :bold),
          ui.color('State', :bold)
        ]

        begin
          connection.servers.all.sort_by(&:id).each do |server|
            server_list << server.id.to_s
            server_list << server.name
            if primary_public_ip_address(server.addresses)
              server_list << primary_public_ip_address(server.addresses)
            else
              server_list << ''
            end
            if primary_private_ip_address(server.addresses)
              server_list << primary_private_ip_address(server.addresses)
            else
              server_list << ''
            end
            server_list << server.flavor['id'].to_s
            server_list << server.image['id'].to_s
            server_list << server.key_name
            server_list << begin
                             state = server.state.to_s.downcase
                             case state
                             when 'shutting-down','terminated','stopping','stopped','error','shutoff'
                               ui.color(state, :red)
                             when 'pending','build','paused','suspended','hard_reboot'
                               ui.color(state, :yellow)
                             else
                               ui.color(state, :green)
                             end
                           end
          end
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
        puts ui.list(server_list, :uneven_columns_across, 8)

      end
    end
  end
end
