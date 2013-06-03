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
require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/list_resource_options'

class Chef
  class Knife
    class OpenstackImageList < Knife

      include Knife::OpenstackBase
      include Knife::Cloud::ResourceListOptions

      banner "knife openstack image list (options)"

      def run
        @cloud_service = Cloud::OpenstackService.new(self)
        @cloud_service.image_list([{:attribute => 'name', :regex => /initrd$|kernel$|loader$|virtual$|vmlinuz$/}])
      end

    end
  end
end
