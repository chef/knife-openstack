require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    module OpenstackHelpers

      def primary_private_ip_address(addresses)
          return addresses['private'].last['addr'] if addresses['private']
      end

      #we use last since the floating IP goes there
      def primary_public_ip_address(addresses)
          return addresses['public'].last['addr'] if addresses['public']
      end

      def is_image_windows?
        # Openstack image info does not have os type, so we use windows_bootstrap_protocol to interpret if we are creating windows server.
        !config[:windows_bootstrap_protocol].nil? ? true : false
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

    end
  end
end
