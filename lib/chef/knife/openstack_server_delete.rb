#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/server/delete_options'
require 'chef/knife/cloud/fog/options'
require 'chef/knife/cloud/server/delete_command'
require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/openstack_service_options'
require 'chef/knife/openstack_helpers'

class Chef
  class Knife
    class Cloud
      class OpenstackServerDelete < ServerDeleteCommand
        include FogOptions
        include ServerDeleteOptions
        include OpenstackServiceOptions
        include OpenstackHelpers

        banner "knife openstack server delete INSTANCEID [INSTANCEID] (options)"

      end
    end
  end
end
