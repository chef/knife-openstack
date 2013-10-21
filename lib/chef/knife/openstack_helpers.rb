require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      module OpenstackHelpers

        def primary_private_ip_address(addresses)
          return addresses['private'].last['addr'] if addresses['private'] && !addresses['private'].empty?
        end

        #we use last since the floating IP goes there
        def primary_public_ip_address(addresses)
          return addresses['public'].last['addr'] if addresses['public'] && !addresses['public'].empty?
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
