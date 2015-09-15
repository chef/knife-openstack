# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      class OpenstackNetworkList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack network list (options)'

        def before_exec_command
          # set columns_with_info map
          @columns_with_info = [
            { label: 'Name', key: 'name' },
            { label: 'ID', key: 'id' },
            { label: 'Tenant', key: 'tenant_id' },
            { label: 'Shared', key: 'shared' }
          ]
          @sort_by_field = 'name'
        end

        def query_resource
          @service.list_networks
        end
      end
    end
  end
end
