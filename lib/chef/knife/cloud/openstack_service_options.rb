
require 'chef/knife/cloud/fog/service_options'

class Chef
  class Knife
    class Cloud
      module OpenstackServiceOptions

       def self.included(includer)
          includer.class_eval do
            include FogServiceOptions

            deps do
              require 'readline'
              require 'chef/json_compat'
            end

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
          end
        end
      end
    end
  end
end