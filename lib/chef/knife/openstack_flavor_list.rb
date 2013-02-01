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
    class OpenstackFlavorList < Knife

      include Knife::OpenstackBase

      banner "knife openstack flavor list (options)"

      def run

        validate!

        flavor_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Virtual CPUs', :bold),
          ui.color('RAM', :bold),
          ui.color('Disk', :bold),
        ]
        begin
          connection.flavors.sort_by(&:id).each do |flavor|
            flavor_list << flavor.id.to_s
            flavor_list << flavor.name
            flavor_list << flavor.vcpus.to_s
            flavor_list << "#{flavor.ram.to_s} MB"
            flavor_list << "#{flavor.disk.to_s} GB"
          end
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
        puts ui.list(flavor_list, :uneven_columns_across, 5)
      end
    end
  end
end
