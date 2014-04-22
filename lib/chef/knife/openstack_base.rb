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

class Chef
  class Knife
    module OpenstackBase

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

          option :openstack_endpoint_type,
            :long => "--openstack-endpoint-type ENDPOINT_TYPE",
            :description => "OpenStack endpoint type to use (publicURL, internalURL, adminURL)",
            :proc => Proc.new { |type| Chef::Config[:knife][:openstack_endpoint_type] = type }

          option :openstack_insecure,
            :long => "--insecure",
            :description => "Ignore SSL certificate on the Auth URL",
            :boolean => true,
            :default => false,
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_insecure] = key }

        end
      end

      def connection
        Chef::Log.debug("openstack_username #{Chef::Config[:knife][:openstack_username]}")
        Chef::Log.debug("openstack_auth_url #{Chef::Config[:knife][:openstack_auth_url]}")
        Chef::Log.debug("openstack_endpoint_type #{Chef::Config[:knife][:openstack_endpoint_type] || 'publicURL' }")
        Chef::Log.debug("openstack_tenant #{Chef::Config[:knife][:openstack_tenant]}")
        Chef::Log.debug("openstack_insecure #{Chef::Config[:knife][:openstack_insecure].to_s}")

        @connection ||= begin
          connection = Fog::Compute.new(
            :provider => 'OpenStack',
            :openstack_username => Chef::Config[:knife][:openstack_username],
            :openstack_api_key => Chef::Config[:knife][:openstack_password],
            :openstack_auth_url => Chef::Config[:knife][:openstack_auth_url],
            :openstack_endpoint_type => Chef::Config[:knife][:openstack_endpoint_type],
            :openstack_tenant => Chef::Config[:knife][:openstack_tenant],
            :connection_options => {
              :ssl_verify_peer => !Chef::Config[:knife][:openstack_insecure]
            }
            )
                        rescue Excon::Errors::Unauthorized => e
                          ui.fatal("Connection failure, please check your OpenStack username and password.")
                          exit 1
                        rescue Excon::Errors::SocketError => e
                          ui.fatal("Connection failure, please check your OpenStack authentication URL.")
                          exit 1
                        end
      end

      def network
        Chef::Log.debug("openstack_username #{Chef::Config[:knife][:openstack_username]}")
        Chef::Log.debug("openstack_auth_url #{Chef::Config[:knife][:openstack_auth_url]}")
        Chef::Log.debug("openstack_tenant #{Chef::Config[:knife][:openstack_tenant]}")
        Chef::Log.debug("openstack_insecure #{Chef::Config[:knife][:openstack_insecure].to_s}")

        @network ||= begin
          network = Fog::Network.new(
            :provider => 'OpenStack',
            :openstack_username => Chef::Config[:knife][:openstack_username],
            :openstack_api_key => Chef::Config[:knife][:openstack_password],
            :openstack_auth_url => Chef::Config[:knife][:openstack_auth_url],
            :openstack_tenant => Chef::Config[:knife][:openstack_tenant],
            :connection_options => {
              :ssl_verify_peer => !Chef::Config[:knife][:openstack_insecure]
            }
            )
                        rescue Excon::Errors::Unauthorized => e
                          ui.fatal("Connection failure, please check your OpenStack username and password.")
                          exit 1
                        rescue Excon::Errors::SocketError => e
                          ui.fatal("Connection failure, please check your OpenStack authentication URL.")
                          exit 1
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

      def validate!(keys=[:openstack_username, :openstack_password, :openstack_auth_url])
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

      def primary_private_ip_address(addresses)
        primary_network_ip_address(addresses, 'private')
      end

      #we use last since the floating IP goes there
      def primary_public_ip_address(addresses)
        primary_network_ip_address(addresses, 'public')
      end

      def primary_network_ip_address(addresses, network_name)
        if addresses[network_name]
          return addresses[network_name].last['addr']
        end
      end

    end
  end
end
