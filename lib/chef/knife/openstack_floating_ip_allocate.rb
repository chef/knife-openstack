# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.

require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/cloud/command'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpAllocate < Command
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack floating_ip allocate (options)'

        option :pool,
          :short => '-p POOL',
          :long => '--pool POOL',
          :description => 'Floating IP pool to allocate from.',
          :proc => Proc.new { |key| Chef::Config[:knife][:pool] = key }

        def execute_command
          @resource = @service.allocate_address(locate_config_value(:pool))
        end

        def after_exec_command
          @columns_with_info = [{ label: 'ID', value: @resource['floating_ip']['id'].to_s },
                                { label: 'Instance ID', value: @resource['floating_ip']['instance_id'].to_s },
                                { label: 'Floating IP', value: @resource['floating_ip']['ip'].to_s },
                                { label: 'Fixed IP', value: @resource['floating_ip']['fixed_ip'].to_s },
                                { label: 'Pool', value: @resource['floating_ip']['pool'].to_s }
                               ]
          @service.server_summary(nil, @columns_with_info)
        end
      end
    end
  end
end
