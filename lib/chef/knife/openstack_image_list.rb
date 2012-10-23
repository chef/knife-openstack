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
    class OpenstackImageList < Knife

      include Knife::OpenstackBase

      banner "knife openstack image list (options)"

      def run

        validate!

        image_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          # ui.color('Kernel ID', :bold),
          # ui.color('Architecture', :bold),
          # ui.color('Root Store', :bold),
          # ui.color('Location', :bold)
        ]

        begin
          connection.images.sort_by do |image|
            [image.name.downcase, image.id].compact
          end.each do |image|
            image_list << image.id
            image_list << image.name
            # image_list << image.kernel_id
            # image_list << image.architecture
            # image_list << image.root_device_type
            # image_list << image.location
          end
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end

        image_list = image_list.map do |item|
          item.to_s
        end

        puts ui.list(image_list, :uneven_columns_across, 2)
      end
    end
  end
end
