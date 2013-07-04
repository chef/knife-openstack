#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/server/delete_options'
require 'chef/knife/cloud/fog/options'
require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/cloud/openstack_service'

class Chef
  class Knife
    class Cloud
      class OpenstackServerDelete < ServerDeleteCommand
        include FogOptions
        include ServerDeleteOptions

        # Openstack Connection params.
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

        banner "knife openstack server delete INSTANCEID [INSTANCEID] (options)"

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

        def create_service_instance
          OpenstackService.new
        end

      end
    end
  end
end
