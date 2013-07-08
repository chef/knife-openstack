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

require 'chef/knife/cloud/server/create_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_server_create_options'
require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/cloud/fog/options'

class Chef
  class Knife
    class Cloud
      class OpenstackServerCreate < ServerCreateCommand
        include FogOptions
        include OpenstackHelpers
        include OpenstackServerCreateOptions
        include OpenstackServiceOptions


        banner "knife openstack server create (options)"

        def before_exec_command
            # setup the create options
            @create_options = {
              :server_def => {
                #servers require a name, generate one if not passed
                :name => get_node_name(locate_config_value(:chef_node_name)),
                :image_ref => locate_config_value(:image),
                :flavor_ref => locate_config_value(:flavor),
                :security_groups => locate_config_value(:openstack_security_groups),
                :key_name => locate_config_value(:openstack_ssh_key_id)
              },
              :server_create_timeout => locate_config_value(:server_create_timeout)
            }
            Chef::Log.debug("Create server params - server_def = #{@create_options[:server_def]}")
            super
        end

        # Setup the floating ip after server creation.
        def after_exec_command
          msg_pair("Flavor", server.flavor['id'])
          msg_pair("Image", server.image['id'])
          Chef::Log.debug("Addresses #{server.addresses}")
          msg_pair("Public IP Address", primary_public_ip_address(server.addresses)) if primary_public_ip_address(server.addresses)

          floating_address = locate_config_value(:openstack_floating_ip)
          Chef::Log.debug("Floating IP Address requested #{floating_address}")
          unless (floating_address == '-1') #no floating IP requested
            addresses = service.connection.addresses
            #floating requested without value
            if floating_address.nil?
              free_floating = addresses.find_index {|a| a.fixed_ip.nil?}
              if free_floating.nil? #no free floating IP found
                ui.error("Unable to assign a Floating IP from allocated IPs.")
                exit 1
              else
                floating_address = addresses[free_floating].ip
              end
            end
            server.associate_address(floating_address)
            #a bit of a hack, but server.reload takes a long time
            (server.addresses['public'] ||= []) << {"version"=>4,"addr"=>floating_address}
            msg_pair("Floating IP Address", floating_address)
          end

          Chef::Log.debug("Addresses #{server.addresses}")
          Chef::Log.debug("Public IP Address actual: #{primary_public_ip_address(server.addresses)}") if primary_public_ip_address(server.addresses)

          msg_pair("Private IP Address", primary_private_ip_address(server.addresses)) if primary_private_ip_address(server.addresses)
          super
        end

        def before_bootstrap
          super
          # Which IP address to bootstrap
          bootstrap_ip_address = primary_public_ip_address(server.addresses) if primary_public_ip_address(server.addresses)
          bootstrap_ip_address = primary_private_ip_address(server.addresses) if config[:private_network]
          Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
          if bootstrap_ip_address.nil?
            ui.error("No IP address available for bootstrapping.")
            raise "No IP address available for bootstrapping."
          end
          config[:bootstrap_ip_address] = bootstrap_ip_address
        end

        def validate!
        end
      end
    end
  end
end
