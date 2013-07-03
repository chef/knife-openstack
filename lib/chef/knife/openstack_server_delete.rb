#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/openstack_service'
require 'chef/knife/cloud/openstack_server_delete_options'
require 'chef/knife/cloud/openstack_service_options'

class Chef
  class Knife
    class OpenstackServerDelete < Knife
      include Knife::Cloud::OpenstackServerDeleteOptions
      include Knife::Cloud::OpenstackServiceOptions
      
      banner "knife openstack server delete SERVER [Instance Id] (options)"

      def run
        $stdout.sync = true
        @cloud_service = Cloud::OpenstackService.new(self)

        @name_args.each do |instance_id|
          @cloud_service.server_delete(instance_id)
        end
      end
    end
  end
end
