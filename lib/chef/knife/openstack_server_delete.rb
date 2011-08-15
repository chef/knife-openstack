#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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
          server = connection.servers.get(instance_id)

          msg("Instance ID", server.id)
          msg("Flavor", server.flavor_id)
          msg("Image", server.image_id)
          msg("Availability Zone", server.availability_zone)
          msg("Security Groups", server.groups.join(", "))
          msg("SSH Key", server.key_name)
          msg("Public DNS Name", server.dns_name)
          msg("Public IP Address", server.public_ip_address)
          msg("Private DNS Name", server.private_dns_name)
          msg("Private IP Address", server.private_ip_address)

          puts "\n"
          confirm("Do you really want to delete this server")

          server.destroy

          ui.warn("Deleted server #{server.id}")
        end
      end

      def msg(label, value)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end

    end
  end
end

