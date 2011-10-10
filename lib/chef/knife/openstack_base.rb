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
    module OpenstackBase

      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'fog'
            require 'readline'
            require 'chef/json_compat'
          end

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

        end
      end

      def connection
        @connection ||= begin
          connection = Fog::Compute.new(
            :provider => 'AWS',
            :aws_access_key_id => Chef::Config[:knife][:openstack_access_key_id],
            :aws_secret_access_key => Chef::Config[:knife][:openstack_secret_access_key],
            :endpoint => Chef::Config[:knife][:openstack_api_endpoint],
            :region => Chef::Config[:knife][:region] || config[:region]
          )
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!(keys=[:openstack_access_key_id, :openstack_secret_access_key, :openstack_api_endpoint])
        errors = []

        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
          if Chef::Config[:knife][k].nil?
            errors << "You did not provide a valid '#{pretty_key}' value."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end

    end
  end
end


