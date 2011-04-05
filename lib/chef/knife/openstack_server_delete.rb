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
    class OpenstackServerDelete < Knife

      deps do
        require 'fog'
        require 'net/ssh/multi'
        require 'readline'
        require 'chef/json_compat'
      end

      banner "knife openstack server delete SERVER [SERVER] (options)"

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

        @name_args.each do |instance_id|
          server = connection.servers.get(instance_id)

          msg("Instance ID", server.id)
          msg("Flavor", server.flavor_id)
          msg("Image", server.image_id)
          msg("Availability Zone", server.availability_zone)
          msg("Security Groups", server.groups.join(", "))
          msg("SSH Key", server.key_name)
          msg("Public DNS Name", server.dns_name)
          msg("Public IP Address", server.ip_address)
          msg("Private DNS Name", server.private_dns_name)
          msg("Private IP Address", server.private_ip_address)

          puts "\n"
          confirm("Do you really want to delete this server")

          server.destroy

          ui.warn("Deleted server #{server.id}")
        end
      end

      def msg(label, value)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end

    end
  end
end

