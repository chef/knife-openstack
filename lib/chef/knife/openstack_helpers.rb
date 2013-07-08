require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      module OpenstackHelpers

        def primary_private_ip_address(addresses)
            return addresses['private'].last['addr'] if addresses['private']
        end

        #we use last since the floating IP goes there
        def primary_public_ip_address(addresses)
            return addresses['public'].last['addr'] if addresses['public']
        end

        def is_image_windows?
          # Openstack image info does not have os type, so we use image_os_type cli option to interpret if we are creating windows server.
          os_type = locate_config_value(:image_os)
          os_type.nil? ? false : (os_type.downcase == 'windows')
        end

        def create_service_instance
          OpenstackService.new
        end
      end
    end
  end
end
