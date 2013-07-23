require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      class OpenstackImageList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner "knife openstack image list (options)"

        option :disable_filter,
          :long => "--disable-filter",
          :description => "Disable filtering of the image list. Currently filters names ending with 'initrd' or 'kernel'",
          :boolean => true,
          :default => false

        def before_exec_command
          #set resource_filters
          if !config[:disable_filter]
            @resource_filters = [{:attribute => 'name', :regex => /initrd$|kernel$|loader$|virtual$|vmlinuz$/}]
          end
          #set columns_with_info map
          @columns_with_info = [
          {:label => 'ID', :key => 'id'}, 
          {:label => 'Name', :key => 'name'},
          {:label => 'Snapshot', :key => 'metadata', :value_callback => method(:is_image_snapshot)}
        ]
        end

        def query_resource
          @service.list_images
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

      end
    end
  end
end