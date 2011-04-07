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

require 'chef/knife'

class Chef
  class Knife
    class OpenstackImageList < Knife

      deps do
        require 'fog'
        require 'chef/json_compat'
      end

      banner "knife openstack image list (options)"

      option :openstack_access_key_id,
        :short => "-A ID",
        :long => "--openstack-access-key-id KEY",
        :description => "Your OpenStack Access Key ID",
        :proc => Proc.new { |key| Chef::Config[:knife][:openstack_access_key_id] = key }

      option :openstack_secret_access_key,
        :short => "-K SECRET",
        :long => "--openstack-secret-access-key SECRET",
        :description => "Your OpenStack API Secret Access Key",
        :proc => Proc.new { |key| Chef::Config[:knife][:openstack_secret_access_key] = key }

      option :openstack_api_endpoint,
        :long => "--openstack-api-endpoint ENDPOINT",
        :description => "Your OpenStack API endpoint",
        :proc => Proc.new { |endpoint| Chef::Config[:knife][:openstack_api_endpoint] = endpoint }

      option :region,
        :long => "--region REGION",
        :description => "Your OpenStack region",
        :proc => Proc.new { |region| Chef::Config[:knife][:region] = region }

      def run
        connection = Fog::Compute.new(
          :provider => 'AWS',
          :aws_access_key_id => Chef::Config[:knife][:openstack_access_key_id],
          :aws_secret_access_key => Chef::Config[:knife][:openstack_secret_access_key],
          :endpoint => Chef::Config[:knife][:openstack_api_endpoint],
          :region => Chef::Config[:knife][:region] || config[:region]
        )

        image_list = [
          ui.color('ID', :bold),
          ui.color('Kernel ID', :bold),
          ui.color('Architecture', :bold),
          ui.color('Root Store', :bold),
          ui.color('Name', :bold),
          ui.color('Location', :bold)
        ]

        connection.images.sort_by do |image|
          [image.name, image.id].compact
        end.each do |image|
          image_list << image.id
          image_list << image.kernel_id
          image_list << image.architecture
          image_list << image.root_device_type
          image_list << image.name
          image_list << image.location
        end

        image_list = image_list.map do |item|
          item.to_s
        end

        puts ui.list(image_list, :columns_across, 6)
      end
    end
  end
end
