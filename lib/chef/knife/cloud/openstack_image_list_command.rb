
require 'chef/knife/cloud/fog/image_list_command'
require 'chef/knife/openstack_helpers'

class Chef
  class Knife
    class Cloud
      class OpenstackImageListCommand < FogImageListCommand

        # For helper methods
        include OpenstackHelpers

        def list(servers, columns_with_info = [])
          # form the columns_with_info and pass on to super
          columns_with_info = [
            { :key => 'id', :label => 'Instance ID' },
            { :key => 'name', :label => 'Name' },
            { :key => 'metadata', :label => 'Snapshot', :value_callback => method(:is_image_snapshot) }
          ]
          super(servers, columns_with_info)
        end

        def is_image_snapshot(metadata)
          snapshot = 'no'
          metadata.each do |datum|
            if (datum.key == 'image_type') && (datum.value == 'snapshot')
              snapshot = 'yes'
            end
          end
          snapshot
        end

      end # class OpenstackImageListCommand
    end
  end
end