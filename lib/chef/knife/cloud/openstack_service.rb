#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/fog/service'
#Todo add missing image list dependency for Chef::Knife::Cloud::FogService
require 'chef/knife/cloud/fog/image_list_command'
require 'chef/knife/cloud/openstack_server_delete_command'

class Chef
  class Knife
    class Cloud
      class OpenstackService < FogService

        def declare_command_classes
          super
          # override the classes
          @delete_server_class = Cloud::OpenstackServerDeleteCommand
        end

        def cloud_auth_params(options)
          Chef::Log.debug("openstack_username #{Chef::Config[:knife][:openstack_username]}")
          Chef::Log.debug("openstack_auth_url #{Chef::Config[:knife][:openstack_auth_url]}")
          Chef::Log.debug("openstack_tenant #{Chef::Config[:knife][:openstack_tenant]}")
          Chef::Log.debug("openstack_insecure #{Chef::Config[:knife][:openstack_insecure].to_s}")

          {
            :provider => 'OpenStack',
            :openstack_username => Chef::Config[:knife][:openstack_username],
            :openstack_api_key => Chef::Config[:knife][:openstack_password],
            :openstack_auth_url => Chef::Config[:knife][:openstack_auth_url],
            :openstack_tenant => Chef::Config[:knife][:openstack_tenant],
            :connection_options => {
              :ssl_verify_peer => !Chef::Config[:knife][:openstack_insecure]
            }
          }
        end
      end
    end
  end
end