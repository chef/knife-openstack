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

# These two are needed for the '--purge' deletion case
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class OpenstackServerDelete < Knife

      include Knife::OpenstackBase

      banner "knife openstack server delete SERVER [SERVER] (options)"

      option :purge,
        :short => "-P",
        :long => "--purge",
        :boolean => true,
        :default => false,
        :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the OpenStack node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."

      # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      def run

        validate!

        @name_args.each do |search_term|
          begin
            server = find_server(search_term)

            msg_pair("Instance Name", server.name)
            msg_pair("Instance ID", server.id)
            msg_pair("Flavor", server.flavor['id'])
            msg_pair("Image", server.image['id'])
            server.addresses.each do |name,addr|
              msg_pair("Network", name)
              msg_pair("  IP Address", addr[0]['addr'])
            end

            puts "\n"
            confirm("Do you really want to delete this server")

            server.destroy

            ui.warn("Deleted server #{server.id}")

            if config[:purge]
              thing_to_delete = config[:chef_node_name] || search_term
              destroy_item(Chef::Node, thing_to_delete, "node")
              destroy_item(Chef::ApiClient, thing_to_delete, "client")
            else
              ui.warn("Corresponding node and client for the #{search_term} server were not deleted and remain registered with the Chef Server")
            end

          rescue NoMethodError
            ui.error("Could not locate server '#{search_term}'.")
          rescue ArgumentError => e
            ui.error(e.message)
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
        end
      end

      private

      def find_server(search_term)
        if server = connection.servers.get(search_term)
          return server
        end

        if servers = connection.servers.all(:name => search_term)
          if servers.length > 1
            raise ArgumentError.new("Multiple server matches found for '#{search_term}', use an instance_id to be more specific")
          else
            servers.first
          end
        end
      end

    end
  end
end
