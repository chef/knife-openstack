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
    class OpenstackVolumeList < Knife

      include Knife::OpenstackBase

      banner "knife openstack volume list (options)"

      def run

        validate!

        volume_list = [
          ui.color('Name', :bold),
          ui.color('ID', :bold),
          ui.color('Status', :bold),
          ui.color('Size', :bold),
          ui.color('Description', :bold),
        ]
        begin
          connection.volumes.sort_by(&:name).each do |volume|
            puts volume.inspect
            volume_list << volume.name
            volume_list << volume.id.to_s
            volume_list << volume.status
            volume_list << "#{volume.size.to_s} GB"
            volume_list << volume.description
          end
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
        puts ui.list(volume_list, :uneven_columns_across, 5)
      end
    end
  end
end
