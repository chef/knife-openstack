#
# Author:: Seth Chisamore (<schisamo@getchef.com>)
# Author:: Matt Ray (<matt@getchef.com>)
# Author:: Evan Felix (<karcaw@gmail.com>)
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

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud 
    class OpenstackVolumeList < ResourceListCommand

      include OpenstackHelpers
      include OpenstackServiceOptions

      banner "knife openstack volume list (options)"

      def before_exec_command
        #set columns_with_info map
        @columns_with_info = [
          {:label => 'Name', :key => 'name' },
          {:label => 'ID', :key => 'id' }, 
          {:label => 'Status', :key => 'status' }, 
          {:label => 'Size', :key => 'size', :value_callback => method(:size_in_gb) }, 
          {:label => 'Description', :key => 'description' }
	    ]
        @sort_by_field = "name"
      end

	  def query_resource
          @service.connection.volumes
      end

      def size_in_gb(size)
         "#{size} GB"
      end
    end
  end
end
end
