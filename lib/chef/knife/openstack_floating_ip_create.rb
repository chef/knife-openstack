# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2014 Chef Software, Inc.

require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpCreate < Command
        include OpenstackHelpers
        include OpenstackServiceOptions

        banner 'knife openstack floating_ip create (options)'

        def execute_command
          @service.allocate_address
        end
      end
    end
  end
end
