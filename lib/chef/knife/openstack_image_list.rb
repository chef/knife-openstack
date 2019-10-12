#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright 2014-2018 Chef Software, Inc.
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
require "chef/knife/openstack_helpers"
require "chef/knife/cloud/openstack_service_options"

class Chef
  class Knife
    class Cloud
      class OpenstackImageList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner "knife openstack image list (options)"

        option :disable_filter,
          long: "--disable-filter",
          description: "Disable filtering of the image list. Currently filters names ending with 'initrd' or 'kernel'",
          boolean: true,
          default: false

        def before_exec_command
          # set resource_filters
          unless config[:disable_filter]
            @resource_filters = [{ attribute: "name", regex: /initrd$|kernel$|loader$|virtual$|vmlinuz$/ }]
          end
          # set columns_with_info map
          @columns_with_info = [
            { label: "Name", key: "name" },
            { label: "ID", key: "id" },
            { label: "Snapshot", key: "metadata", value_callback: method(:is_image_snapshot) },
          ]
          @sort_by_field = "name"
        end

        def query_resource
          @service.list_images
        end

        def is_image_snapshot(metadata)
          snapshot = "no"
          metadata.each do |datum|
            if (datum.key == "image_type") && (datum.value == "snapshot")
              snapshot = "yes"
            end
          end
          snapshot
        end
      end
    end
  end
end
