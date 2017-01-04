# frozen_string_literal: true
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.

require "chef/knife/cloud/list_resource_command"
require "chef/knife/openstack_helpers"
require "chef/knife/cloud/openstack_service_options"

class Chef
  class Knife
    class Cloud
      class OpenstackFlavorList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner "knife openstack flavor list (options)"

        def before_exec_command
          # set columns_with_info map
          @columns_with_info = [
            { label: "Name", key: "name" },
            { label: "ID", key: "id" },
            { label: "Virtual CPUs", key: "vcpus" },
            { label: "RAM", key: "ram", value_callback: method(:ram_in_mb) },
            { label: "Disk", key: "disk", value_callback: method(:disk_in_gb) },
          ]
          @sort_by_field = "name"
        end

        def query_resource
          @service.list_resource_configurations
        end

        def ram_in_mb(ram)
          "#{ram} MB"
        end

        def disk_in_gb(disk)
          "#{disk} GB"
        end
      end
    end
  end
end
