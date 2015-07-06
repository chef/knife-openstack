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
      class OpenstackFloatingIpRelease < Command
        include OpenstackServiceOptions
        include OpenstackHelpers

        banner 'knife openstack floating_ip release ID [ID] (options)'

        def execute_command
          service.release_address(@name_args[0])
        end
      end
    end
  end
end
