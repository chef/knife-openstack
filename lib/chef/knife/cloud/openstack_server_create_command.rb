require 'chef/knife/cloud/fog/server_create_command'
require 'chef/knife/openstack_helpers'

class Chef
  class Knife
    class Cloud
      class OpenstackServerCreateCommand < FogServerCreateCommand

        # For helper methods
        include OpenstackHelpers

        def create_server_def()
          server_def = {
            #servers require a name, generate one if not passed
            :name => get_node_name(@app.config[:chef_node_name]),
            :image_ref => @app.locate_config_value(:image),
            :flavor_ref => @app.locate_config_value(:flavor),
            :security_groups => @app.locate_config_value(:openstack_security_groups),
            :key_name => @app.locate_config_value(:openstack_ssh_key_id)
          }
          Chef::Log.debug("server_def = #{server_def}")
          server_def
        end

        #generate a random name if chef_node_name is empty
        def get_node_name(chef_node_name)
          return chef_node_name unless chef_node_name.nil?
          #lazy uuids
          chef_node_name = "os-"+rand.to_s.split('.')[1]
        end

        def after_handler
          msg_pair("Flavor", server.flavor['id'])
          msg_pair("Image", server.image['id'])
          # msg_pair("SSH Identity File", config[:identity_file])
          # msg_pair("SSH Keypair", server.key_name) if server.key_name
          # msg_pair("SSH Password", server.password) if (server.password && !server.key_name)
          Chef::Log.debug("Addresses #{server.addresses}")
          msg_pair("Public IP Address", primary_public_ip_address(server.addresses)) if primary_public_ip_address(server.addresses)

          floating_address = @app.locate_config_value(:openstack_floating_ip)
          Chef::Log.debug("Floating IP Address requested #{floating_address}")
          unless (floating_address == '-1') #no floating IP requested
            addresses = @service.connection.addresses
            #floating requested without value
            if floating_address.nil?
              free_floating = addresses.find_index {|a| a.fixed_ip.nil?}
              if free_floating.nil? #no free floating IP found
                ui.error("Unable to assign a Floating IP from allocated IPs.")
                exit 1
              else
                floating_address = addresses[free_floating].ip
              end
            end
            server.associate_address(floating_address)
            #a bit of a hack, but server.reload takes a long time
            (server.addresses['public'] ||= []) << {"version"=>4,"addr"=>floating_address}
            msg_pair("Floating IP Address", floating_address)
          end

          Chef::Log.debug("Addresses #{server.addresses}")
          Chef::Log.debug("Public IP Address actual: #{primary_public_ip_address(server.addresses)}") if primary_public_ip_address(server.addresses)

          msg_pair("Private IP Address", primary_private_ip_address(server.addresses)) if primary_private_ip_address(server.addresses)
        end

        def before_bootstrap
          # Which IP address to bootstrap
          bootstrap_ip_address = primary_public_ip_address(server.addresses) if primary_public_ip_address(server.addresses)
          if @app.config[:private_network]
            bootstrap_ip_address = primary_private_ip_address(server.addresses)
          end

          Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
          if bootstrap_ip_address.nil?
            ui.error("No IP address available for bootstrapping.")
            raise "No IP address available for bootstrapping."
          end
          @app.config[:bootstrap_ip_address] = bootstrap_ip_address

          # let ohai know we're using OpenStack
          Chef::Config[:knife][:hints] ||= {}
          Chef::Config[:knife][:hints]['openstack'] ||= {}
        end

      end
    end
  end
end