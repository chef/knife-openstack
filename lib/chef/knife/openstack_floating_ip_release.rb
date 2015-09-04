#
# Author:: Vasundhara Jagdale (<vasundhara.jagdale@clogeny.com>)
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
#

require 'chef/knife/openstack_helpers'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/cloud/command'

class Chef
  class Knife
    class Cloud
      class OpenstackFloatingIpRelease < Command
        include OpenstackServiceOptions
        include OpenstackHelpers

        banner 'knife openstack floating_ip release ID [ID] (options)'

        def execute_command
          if @name_args[0]
            response = service.release_address(@name_args[0])
            if response && response.status == 202
              ui.info 'Floating IP released successfully.'
            end
          else
            ui.error 'Please provide Floating IP to release.'
            exit 1
          end
        end
      end
    end
  end
end
