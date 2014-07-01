#
# Author:: Florin STAN (<florin.stan@gmail.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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

      option :os_module,
        :long => '--os-module (Nova|Cinder)',
        :description => 'Openstack API That is going to be used. Default is Nova',
        :default => 'Nova',
        :require => false


      def run
        validate!

        volume_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Status', :bold),
          ui.color('Zone', :bold),
          ui.color('Device', :bold),
          ui.color('Attached to Server', :bold),
        ]

        target = locate_config_value(:os_module)
        c = storage(target)

        begin
          vol_list = c.volumes.sort_by(&:name) if 'Nova' == target
          vol_list = c.volumes.sort_by(&:display_name) if 'Cinder' == target
          vol_list.each do |volume|
            volume_list << volume.id.to_s
            if defined? volume.name
              volume_list << volume.name
            else
              volume_list << volume.display_name
            end
            volume_list << status_color(volume.status)
            volume_list << volume.availability_zone
            if volume.attachments.size > 0
              volume_list << volume.attachments[0]["device"]
              volume_list << get_server_by_id(volume.attachments[0]["server_id"]) if 'Cinder' == target
              volume_list << get_server_by_id(volume.attachments[0]["serverId"]) if 'Nova' == target
            else
              volume_list << ""
              volume_list << ""
            end
          end
        rescue  Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
        puts ui.list(volume_list, :uneven_columns_across, 6)
      end
    end
  end
end

