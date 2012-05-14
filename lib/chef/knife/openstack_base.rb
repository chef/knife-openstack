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

          option :openstack_username,
            :short => "-A USERNAME",
            :long => "--openstack-username KEY",
            :description => "Your OpenStack Username",
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_username] = key }

          option :openstack_password,
            :short => "-K SECRET",
            :long => "--openstack-password SECRET",
            :description => "Your OpenStack Password",
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_password] = key }

          option :openstack_tenant,
            :short => "-T ID",
            :long => "--openstack-tenant ID",
            :description => "Your OpenStack Tenant ID",
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_tenant] = key }

          option :openstack_auth_url,
            :long => "--openstack-api-endpoint ENDPOINT",
            :description => "Your OpenStack API endpoint",
            :proc => Proc.new { |endpoint| Chef::Config[:knife][:openstack_auth_url] = endpoint }
        end
      end

      def connection
        @connection ||= begin
          connection = Fog::Compute.new(
            :provider => 'OpenStack',
            :openstack_username => Chef::Config[:knife][:openstack_username],
            :openstack_api_key => Chef::Config[:knife][:openstack_password],
            :openstack_auth_url => Chef::Config[:knife][:openstack_auth_url],
            :openstack_tenant => Chef::Config[:knife][:openstack_tenant]
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

      def validate!(keys=[:openstack_username, :openstack_password, :openstack_auth_url, :openstack_tenant])
        errors = []

        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
          if Chef::Config[:knife][k].nil?
            errors << "You did not provided a valid '#{pretty_key}' value."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end

    end
  end
end


