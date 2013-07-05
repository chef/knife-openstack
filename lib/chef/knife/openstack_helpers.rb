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

        def validate!(keys=[:openstack_username, :openstack_password, :openstack_auth_url])
          errors = []

          keys.each do |k|
            pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
            if Chef::Config[:knife][k].nil?
              errors << "You did not provided a valid '#{pretty_key}' value."
            end
          end

          if errors.each{|e| ui.error(e)}.any?
            exit 1
          end
        end

      end
    end
  end
end
