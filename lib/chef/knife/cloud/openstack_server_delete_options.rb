#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#


require 'chef/knife/cloud/server/delete_options'

class Chef
  class Knife
    class Cloud
      module OpenstackServerDeleteOptions
        def self.included(includer)
          includer.class_eval do
            include ServerDeleteOptions
          end
        end
      end
    end
  end
end
