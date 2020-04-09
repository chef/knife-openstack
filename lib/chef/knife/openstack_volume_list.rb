#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Matt Ray (<matt@chef.io>)
# Author:: Evan Felix (<karcaw@gmail.com>)
# Author:: Lance Albertson (<lance@osuosl.org>)
# Copyright:: Copyright 2011-2018 Chef Software, Inc.
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

require "chef/knife/cloud/list_resource_command"
require_relative "openstack_helpers"
require_relative "cloud/openstack_service_options"
require "chef/json_compat"

class Chef
  class Knife
    class Cloud
      class OpenstackVolumeList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner "knife openstack volume list (options)"

        def query_resource
          @service.connection.volumes.all({})
        rescue Excon::Errors::BadRequest => e
          response = Chef::JSONCompat.from_json(e.response.body)
          ui.fatal("Unknown server error (#{response["badRequest"]["code"]}): #{response["badRequest"]["message"]}")
          raise e
        end

        def list(volumes)
          volume_list = [
            ui.color("Name", :bold),
            ui.color("ID", :bold),
            ui.color("Status", :bold),
            ui.color("Size", :bold),
            ui.color("Description", :bold),
          ]
          begin
            volumes.sort_by(&:name).each do |volume|
              volume_list << volume.name
              volume_list << volume.id.to_s
              volume_list << volume.status
              volume_list << "#{volume.size} GB"
              volume_list << volume.description
            end
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response["badRequest"]["code"]}): #{response["badRequest"]["message"]}")
            raise e
          end
          puts ui.list(volume_list, :uneven_columns_across, 5)
        end
      end
    end
  end
end
