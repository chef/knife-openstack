require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      module OpenstackHelpers

        def primary_private_ip_address(addresses)
          primary_network_ip_address(addresses, 'private')
        end

        def primary_public_ip_address(addresses)
          primary_network_ip_address(addresses, 'public')
        end

        def primary_network_ip_address(addresses, network_name)
          return addresses[network_name].last['addr'] if addresses[network_name] && !addresses[network_name].empty?
        end

        def create_service_instance
          OpenstackService.new
        end

        def validate!
          super(:openstack_username, :openstack_password, :openstack_auth_url)
        end
      end
    end
  end
end
