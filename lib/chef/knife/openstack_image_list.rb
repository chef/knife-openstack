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
    class OpenstackImageList < Knife

      include Knife::OpenstackBase

      banner "knife openstack image list (options)"

      option :disable_filter,
      :long => "--disable-filter",
      :description => "Disable filtering of the image list. Currently filters names ending with 'initrd' or 'kernel'",
      :boolean => true,
      :default => false

      def run

        validate!

        image_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Snapshot', :bold),
        ]
        begin
          connection.images.sort_by do |image|
            [image.name.to_s.downcase, image.id].compact
          end.each do |image|
            unless ((image.name =~ /initrd$|kernel$|loader$|virtual$|vmlinuz$/) &&
                !config[:disable_filter])
              image_list << image.id
              image_list << image.name
              snapshot = 'no'
              image.metadata.each do |datum|
                if (datum.key == 'image_type') && (datum.value == 'snapshot')
                  snapshot = 'yes'
                end
              end
              image_list << snapshot
            end
          end
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
        puts ui.list(image_list, :uneven_columns_across, 3)
      end
    end
  end
end
