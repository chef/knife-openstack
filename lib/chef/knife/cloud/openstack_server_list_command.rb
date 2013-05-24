
require 'chef/knife/cloud/fog/server_list_command'
require 'chef/knife/openstack_helpers'

class Chef
  class Knife
    class Cloud
      class OpenstackServerListCommand < FogServerListCommand

        # For helper methods
        include OpenstackHelpers

        def handleResponse(servers, columns_with_info = [])
          puts "OpenstackServerListCommand#handleResponse"
          # form the columns_with_info and pass on to super
          columns_with_info = [
            { :key => 'id', :label => 'Instance ID' },
            { :key => 'name', :label => 'Name' },
            { :key => 'addresses', :label => 'Public IP', :formatter_callback => method(:primary_public_ip_address) },
            { :key => 'addresses', :label => 'Private IP', :formatter_callback => method(:primary_private_ip_address) },
            { :key => 'flavor', :label => 'Flavor', :formatter_callback => method(:format_flavor) },
            { :key => 'image', :label => 'Image', :formatter_callback => method(:format_image) },
            { :key => 'key_name', :label => 'Keypair' },
            { :key => 'state', :label => 'State', :formatter_callback => method(:format_server_state)}
          ]
          super(servers, columns_with_info)
        end

        def format_image(image)
          image['id'].to_s
        end

        def format_flavor(flavor)
          flavor['id'].to_s
        end

      end # class OpenstackServerListCommand
    end
  end
end