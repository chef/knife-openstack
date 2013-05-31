
require 'chef/knife/cloud/list_resource_command'

class Chef
  class Knife
    class Cloud
      class OpenstackFlavorListCommand < ResourceListCommand

        # For helper methods
        include OpenstackHelpers

        def query_resource
          @service.connection.flavors.all
        end

        def list(flavors, columns_with_info = [])
          # form the columns_with_info and pass on to super
          columns_with_info = [
            { :key => 'id', :label => 'ID' },
            { :key => 'name', :label => 'Name' },
            { :key => 'vcpus', :label => 'Virtual CPUs' },
            { :key => 'ram', :label => 'RAM', :value_callback => method(:format_ram_message) },
            { :key => 'disk', :label => 'Disk', :value_callback => method(:format_disk_message) }
          ]
          super(flavors, columns_with_info)
        end

        def format_ram_message(ram)
          "#{ram.to_s} MB"
        end

        def format_disk_message(disk)
          "#{disk.to_s} GB"
        end

      end # class OpenstackFlavorListCommand
    end
  end
end