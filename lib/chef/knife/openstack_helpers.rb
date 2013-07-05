require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    module OpenstackHelpers

      def primary_private_ip_address(addresses)
        if addresses['private']
          return addresses['private'].last['addr']
        end
      end

      #we use last since the floating IP goes there
      def primary_public_ip_address(addresses)
        if addresses['public']
          return addresses['public'].last['addr']
        end
      end

      def self.included(includer)
        includer.class_eval do
          include Cloud::OpenstackServiceOptions
        end
      end

      def is_image_windows?
        # Openstack image info does not have os type, so we use windows_bootstrap_protocol to interpret if we are creating windows server.
        if not config[:windows_bootstrap_protocol].nil?
          true
        else
          false
        end
      end

    end
  end
end
