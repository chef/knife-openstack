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

require 'fog'
require 'chef/knife/openstack_helpers'

class Chef
  class Knife
    module OpenstackBase

      include OpenstackHelpers

      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'chef/json_compat'
            require 'chef/knife'
            require 'readline'
            Chef::Knife.load_deps
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
            :short => "-T NAME",
            :long => "--openstack-tenant NAME",
            :description => "Your OpenStack Tenant NAME",
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_tenant] = key }

          option :openstack_auth_url,
            :long => "--openstack-api-endpoint ENDPOINT",
            :description => "Your OpenStack API endpoint",
            :proc => Proc.new { |endpoint| Chef::Config[:knife][:openstack_auth_url] = endpoint }

          option :openstack_insecure,
            :long => "--insecure",
            :description => "Ignore SSL certificate on the Auth URL",
            :boolean => true,
            :default => false,
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_insecure] = key }
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

    end
  end
end


