#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Chef Software, Inc.
#
\
require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpDelete < Command
        include OpenstackServiceOptions
        include OpenstackHelpers

        banner 'knife openstack floating_ip delete id [ID] (options)'

        def execute_command
          @name_args.each do |id|
            service.delete_address(id)
          end
        end
      end
    end
  end
end