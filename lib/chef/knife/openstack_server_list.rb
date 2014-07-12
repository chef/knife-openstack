#
# Author:: Seth Chisamore (<schisamo@getchef.com>)
# Author:: Matt Ray (<matt@getchef.com>)
# Copyright:: Copyright (c) 2011-2014 Chef Software, Inc.
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
          ui.color('Name', :bold),
          ui.color('Instance ID', :bold),
          ui.color('Zone', :bold),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('Keypair', :bold),
          ui.color('State', :bold)
        ]

        begin
          connection.servers.all.sort_by(&:name).each do |server|
            server_list << server.name
            server_list << server.id.to_s
            server_list << server.availability_zone
	###################################################################################################
	# no IP information is showing up for my implementation when using knife-openstack, which is a PITA
	# I don't think 'net1' is generic ... more work to do here
	# set up for all networks; a hack includes I presume net1 to be a key
	# otherwise, on Havana, I get no IP information from a server list
	##################################################################################################
	    all_ips = JSON.parse(server.addresses['net1'].to_json) 	# all IP addr names
	    fixed = JSON.parse(all_ips[0].to_json) 			# the 1st IP is fixed, for my install
            floater = JSON.parse(all_ips[1].to_json)			# the 2nd IP is floating, for my install
	    
            if floater['addr'] != ""
	      server_list << floater['addr']
	    elsif primary_public_ip_address(server.addresses)
              server_list << primary_public_ip_address(server.addresses)
            else
              server_list << ''
            end


            if fixed['addr'] != ""
	      server << fixed['addr']
	    elsif primary_private_ip_address(server.addresses)
              server_list << primary_private_ip_address(server.addresses)
            else
              server_list << ''
            end

            server_list << server.flavor['id'].to_s
            if server.image
              server_list << server.image['id']
            else
              server_list << ""
            end
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
        puts ui.list(server_list, :uneven_columns_across, 9)

      end
    end
  end
end
