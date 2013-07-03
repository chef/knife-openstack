#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/fog/server_delete_command'

class Chef
  class Knife
    class Cloud
      class OpenstackServerDeleteCommand < FogServerDeleteCommand
        #Add advance behaviour to this class or override base class methods, if required
      end
    end
  end
end