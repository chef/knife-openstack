#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/fog/service'

class Chef
  class Knife
    class Cloud
      class OpenstackService < FogService

        def initialize(options = {})
          Chef::Log.debug("openstack_username #{Chef::Config[:knife][:openstack_username]}")
          Chef::Log.debug("openstack_auth_url #{Chef::Config[:knife][:openstack_auth_url]}")
          Chef::Log.debug("openstack_tenant #{Chef::Config[:knife][:openstack_tenant]}")
          Chef::Log.debug("openstack_insecure #{Chef::Config[:knife][:openstack_insecure].to_s}")

          super(options.merge({
                              :auth_params => {
                                :provider => 'OpenStack',
                                :openstack_username => Chef::Config[:knife][:openstack_username],
                                :openstack_api_key => Chef::Config[:knife][:openstack_password],
                                :openstack_auth_url => Chef::Config[:knife][:openstack_auth_url],
                                :openstack_tenant => Chef::Config[:knife][:openstack_tenant],
                                :connection_options => {
                                  :ssl_verify_peer => !Chef::Config[:knife][:openstack_insecure]
                                }
                }}))
        end

        # add alternate user defined api_endpoint value.
        def add_api_endpoint
          @auth_params.merge!({:openstack_auth_url => Chef::Config[:knife][:api_endpoint]}) unless Chef::Config[:knife][:api_endpoint].nil?
        end
      end
    end
  end
end
