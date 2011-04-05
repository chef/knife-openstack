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
    class OpenstackFlavorList < Knife

      deps do
        require 'fog'
        require 'chef/json_compat'
      end
      
      banner "knife openstack flavor list (options)"

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

        flavor_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Architecture', :bold),
          ui.color('RAM', :bold),
          ui.color('Disk', :bold),
          ui.color('Cores', :bold)
        ]
        connection.flavors.sort_by(&:id).each do |flavor|
          flavor_list << flavor.id.to_s
          flavor_list << flavor.name
          flavor_list << "#{flavor.bits.to_s}-bit"
          flavor_list << "#{flavor.ram.to_s}"
          flavor_list << "#{flavor.disk.to_s} GB"
          flavor_list << flavor.cores.to_s
        end
        puts ui.list(flavor_list, :columns_across, 6)
      end
    end
  end
end
