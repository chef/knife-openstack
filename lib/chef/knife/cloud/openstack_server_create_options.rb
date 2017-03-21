
# frozen_string_literal: true
require "chef/knife/cloud/server/create_options"

class Chef
  class Knife
    class Cloud
      module OpenstackServerCreateOptions
        def self.included(includer)
          includer.class_eval do
            include ServerCreateOptions

            # Openstack Server create params.
            option :private_network,
                   long: "--openstack-private-network",
                   description: "Use the private IP for bootstrapping rather than the public IP",
                   boolean: true,
                   default: false

            option :openstack_floating_ip,
                   short: "-a [IP]",
                   long: "--openstack-floating-ip [IP]",
                   default: "-1",
                   description: "Request to associate a floating IP address to the new OpenStack node. Assumes IPs have been allocated to the project. Specific IP is optional."

            option :openstack_volumes,
                   long: "--openstack-volumes VOLUME1,VOLUME2,VOLUME3",
                   description: "Comma separated list of the UUID(s) of the volume(s) to attach to the server",
                   proc: proc { |volumes| volumes.split(",") }

            option :openstack_scheduler_hints,
                   long: "--scheduler-hints HINTS",
                   description: "A scheduler group hint to OpenStack",
                   proc: proc { |i| Chef::Config[:knife][:openstack_scheduler_hints] = i }

            option :openstack_security_groups,
                   short: "-G X,Y,Z",
                   long: "--openstack-groups X,Y,Z",
                   description: "The security groups for this server",
                   default: ["default"],
                   proc: proc { |groups| groups.split(",") }

            option :openstack_ssh_key_id,
                   short: "-S KEY",
                   long: "--openstack-ssh-key-id KEY",
                   description: "The OpenStack SSH keypair id",
                   proc: proc { |key| Chef::Config[:knife][:openstack_ssh_key_id] = key }

            option :user_data,
                   long: "--user-data USER_DATA",
                   description: "The file path containing user data information for this server",
                   proc: proc { |user_data| open(user_data, &:read) }

            option :bootstrap_network,
                   long: "--bootstrap-network NAME",
                   default: "public",
                   description: "Specify network for bootstrapping. Default is 'public'."

            option :network,
                   long: "--no-network",
                   boolean: true,
                   default: true,
                   description: "Use first available network for bootstrapping if 'public' and 'private' are unavailable."

            option :network_ids,
                   long: "--network-ids NETWORK_ID_1,NETWORK_ID_2,NETWORK_ID_3",
                   description: "Comma separated list of the UUID(s) of the network(s) for the server to attach",
                   proc: proc { |networks| networks.split(",") }

            option :availability_zone,
                   short: "-Z ZONE_NAME",
                   long: "--availability-zone ZONE_NAME",
                   description: "The availability zone for this server",
                   proc: proc { |z| Chef::Config[:knife][:availability_zone] = z }

            option :metadata,
                   short: "-M X=1",
                   long: "--metadata X=1",
                   description: "Metadata information for this server (may pass multiple times)",
                   proc: proc { |data| Chef::Config[:knife][:metadata] ||= {}; Chef::Config[:knife][:metadata].merge!(data.split("=")[0] => data.split("=")[1]) }

            option :secret_file,
                   long: "--secret-file SECRET_FILE",
                   description: "A file containing the secret key to use to encrypt data bag item values",
                   proc: proc { |sf| Chef::Config[:knife][:secret_file] = sf }

            option :secret,
                   long: "--secret ",
                   description: "The secret key to use to encrypt data bag item values",
                   proc: proc { |s| Chef::Config[:knife][:secret] = s }
          end
        end
      end
    end
  end
end
