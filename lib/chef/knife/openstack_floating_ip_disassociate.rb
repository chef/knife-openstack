# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.

require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/command'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpDisassociate < Command
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack floating_ip disassociate IP (options)'

        option :instance_id,
          :long => '--instance-id ID',
          :description => 'Instance id to disassociate with.',
          :proc => Proc.new { |key| Chef::Config[:knife][:instance_id] = key },
          :required => true

        def execute_command
          if @name_args[0]
            floating_ip = @name_args[0]
          else
            ui.error 'Please provide Floating IP to disassociate.'
            exit 1
          end
          instance_id = locate_config_value(:instance_id)
          response =  @service.disassociate_address(instance_id, floating_ip)
          if response && response.status == 202
            ui.info "Floating IP #{floating_ip} disassociated with Instance #{instance_id}"
          end
        end
      end
    end
  end
end
