
require 'chef/knife/cloud/fog/server_list_command'
require 'chef/knife/openstack_helpers'

class Chef
  class Knife
    class Cloud
      class OpenstackServerListCommand < FogServerListCommand

        # For helper methods
        include OpenstackHelpers

        def list(servers, columns_with_info = [])
          # form the columns_with_info and pass on to super
          columns_with_info = [
            { :key => 'id', :label => 'Instance ID' },
            { :key => 'name', :label => 'Name' },
            { :key => 'addresses', :label => 'Public IP', :value_callback => method(:primary_public_ip_address) },
            { :key => 'addresses', :label => 'Private IP', :value_callback => method(:primary_private_ip_address) },
            { :key => 'flavor', :label => 'Flavor', :value_callback => method(:flavor_id) },
            { :key => 'image', :label => 'Image', :value_callback => method(:image_id) },
            { :key => 'key_name', :label => 'Keypair' },
            { :key => 'state', :label => 'State', :value_callback => method(:format_server_state)}
          ]
          super(servers, columns_with_info)
        end

        def image_id(image)
          image['id'].to_s
        end

        def flavor_id(flavor)
          flavor['id'].to_s
        end

      end # class OpenstackServerListCommand
    end
  end
end