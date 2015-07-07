# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.

require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/cloud/openstack_service'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpAssociate < Command
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack floating_ip associate IP (options)'

        option :instance_id,
          :long => '--instance-id ID',
          :description => 'Instance id to associate it with.',
          :proc => Proc.new { |key| Chef::Config[:knife][:instance_id] = key }

        def execute_command
          floating_ip = @name_args[0]
          instance_id = locate_config_value(:instance_id)
          response = @service.associate_address(instance_id, floating_ip)
          if response && response.status == 202
            ui.info "Floating IP #{floating_ip} associated with Instance #{instance_id}"
          end
        end
      end
    end
  end
end
