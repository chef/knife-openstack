
require 'chef/knife/cloud/fog/service'
require 'chef/knife/cloud/openstack_server_list_command'
require 'chef/knife/cloud/openstack_server_create_command'
require 'chef/knife/cloud/openstack_image_list_command'
require 'chef/knife/cloud/openstack_flavor_list_command'
require 'chef/knife/cloud/openstack_group_list_command'

class Chef
  class Knife
    class Cloud
      class OpenstackService < FogService
        attr_accessor :list_flavor_class, :list_group_class

        def declare_command_classes
          super
          # override the classes
          @create_server_class = Cloud::OpenstackServerCreateCommand
          @list_servers_class = Cloud::OpenstackServerListCommand
          @list_image_class = Cloud::OpenstackImageListCommand
          @list_flavor_class = Cloud::OpenstackFlavorListCommand
          @list_group_class = Cloud::OpenstackGroupListCommand
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

        def flavor_list(flavor_filters = nil)
          # creates a flavor_list_command instance
          @cmd = list_flavor_class.new(@app, self)
          @cmd.run(flavor_filters)
        end

        def group_list(group_filters = nil)
          # creates a group instance
          @cmd = list_group_class.new(@app, self)
          @cmd.run(group_filters)
        end

      end
    end
  end
end