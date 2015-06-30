# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.

require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpList < ResourceListCommand
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack floating_ip list (options)'

        def before_exec_command
          # set columns_with_info map
          @columns_with_info = [
            { label: 'ID', key: 'id' },
            { label: 'Instance ID', key: 'instance_id' },
            { label: 'IP Address', key: 'ip' },
            { label: 'Fixed IP', key: 'fixed_ip' },
            { label: 'Floating IP Pool', key: 'pool' }
          ]
        end

        def query_resource
          @service.list_addresses
        end
      end
    end
  end
end
