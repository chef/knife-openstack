

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
    end
  end
end