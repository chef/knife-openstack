
require 'chef/knife/cloud/server/create_options'

class Chef
  class Knife
    class Cloud
      module OpenstackServerCreateOptions

       def self.included(includer)
          includer.class_eval do
            include ServerCreateOptions

            # Openstack Server create params.
            option :openstack_private_network,
            :long => "--openstack-private-network",
            :description => "Use the private IP for bootstrapping rather than the public IP",
            :boolean => true,
            :default => false

            option :openstack_floating_ip,
            :short => "-a [IP]",
            :long => "--openstack-floating-ip [IP]",
            :default => "-1",
            :description => "Request to associate a floating IP address to the new OpenStack node. Assumes IPs have been allocated to the project. Specific IP is optional."

            option :openstack_security_groups,
            :short => "-G X,Y,Z",
            :long => "--openstack-groups X,Y,Z",
            :description => "The security groups for this server",
            :default => ["default"],
            :proc => Proc.new { |groups| groups.split(',') }

            option :openstack_ssh_key_id,
            :short => "-S KEY",
            :long => "--openstack-ssh-key-id KEY",
            :description => "The OpenStack SSH keypair id",
            :proc => Proc.new { |key| Chef::Config[:knife][:openstack_ssh_key_id] = key }

          end
        end
      end
    end
  end
end
