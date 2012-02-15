#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Matt Ray (<matt@opscode.com>)
# Copyright:: Copyright (c) 2011-2012 Opscode, Inc.
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
    class OpenstackServerDelete < Knife

      include Knife::OpenstackBase

      banner "knife openstack server delete SERVER [SERVER] (options)"

      def run

        validate!

        @name_args.each do |instance_id|
          begin
            server = connection.servers.get(instance_id)

            msg_pair("Instance ID", server.id)
            msg_pair("Instance Name", server.name)
            msg_pair("Flavor", server.flavor['id'])
            msg_pair("Image", server.image['id'])
            msg_pair("Public IP Address", server.public_ip_address['addr'])
            msg_pair("Private IP Address", server.private_ip_address['addr'])

            puts "\n"
            confirm("Do you really want to delete this server")

            server.destroy

            ui.warn("Deleted server #{server.id}")
          rescue NoMethodError
            ui.error("Could not locate server '#{instance_id}'.")
          end
        end
      end

    end
  end
end
