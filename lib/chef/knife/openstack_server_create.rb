#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Matt Ray (<matt@opscode.com>)
# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2011-2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/openstack_base'
require 'chef/knife/cloud/openstack_server_create_options'

class Chef
  class Knife
    class OpenstackServerCreate < Knife

      include Knife::OpenstackBase
      include Knife::Cloud::OpenstackServerCreateOptions

      banner "knife openstack server create (options)"

      attr_accessor :initial_sleep_delay


      # def tcp_test_ssh(hostname)
      #   tcp_socket = TCPSocket.new(hostname, 22)
      #   readable = IO.select([tcp_socket], nil, nil, 5)
      #   if readable
      #     Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
      #     yield
      #     true
      #   else
      #     false
      #   end
      # rescue Errno::ETIMEDOUT
      #   false
      # rescue Errno::EPERM
      #   false
      # rescue Errno::ECONNREFUSED
      #   sleep 2
      #   false
      # rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
      #   sleep 2
      #   false
      # rescue Errno::ENETUNREACH
      #   sleep 2
      #   false
      # ensure
      #   tcp_socket && tcp_socket.close
      # end

      # def tcp_test_winrm(hostname, port)
      #   TCPSocket.new(hostname, port)
      #   return true
      # rescue SocketError
      #   sleep 2
      #   false
      # rescue Errno::ETIMEDOUT
      #   false
      # rescue Errno::EPERM
      #   false
      # rescue Errno::ECONNREFUSED
      #   sleep 2
      #   false
      # rescue Errno::EHOSTUNREACH
      #   sleep 2
      #   false
      # rescue Errno::ENETUNREACH
      #   sleep 2
      #   false
      # end

      # def load_winrm_deps
      #   require 'winrm'
      #   require 'em-winrm'
      #   require 'chef/knife/bootstrap_windows_winrm'
      #   require 'chef/knife/core/windows_bootstrap_context'
      #   require 'chef/knife/winrm'
      # end
    #   def run
    #     $stdout.sync = true

    #     validate!
    #     if locate_config_value(:bootstrap_protocol) == 'winrm'
    #       load_winrm_deps
    #     end
    #     #servers require a name, generate one if not passed
    #     node_name = get_node_name(config[:chef_node_name])

    #     server_def = {
    #     :name => node_name,
    #     :image_ref => locate_config_value(:image),
    #     :flavor_ref => locate_config_value(:flavor),
    #     :security_groups => locate_config_value(:security_groups),
    #     :key_name => locate_config_value(:openstack_ssh_key_id)
    #   }

    #   Chef::Log.debug("Name #{node_name}")
    #   Chef::Log.debug("Image #{locate_config_value(:image)}")
    #   Chef::Log.debug("Flavor #{locate_config_value(:flavor)}")
    #   Chef::Log.debug("Requested Floating IP #{locate_config_value(:floating_ip)}")
    #   Chef::Log.debug("Security Groups #{locate_config_value(:security_groups)}")
    #   Chef::Log.debug("Creating server #{server_def}")

    #   begin
    #     server = connection.servers.create(server_def)
    #   rescue Excon::Errors::BadRequest => e
    #     response = Chef::JSONCompat.from_json(e.response.body)
    #     if response['badRequest']['code'] == 400
    #       if response['badRequest']['message'] =~ /Invalid flavorRef/
    #         ui.fatal("Bad request (400): Invalid flavor specified: #{server_def[:flavor_ref]}")
    #         exit 1
    #       else
    #         ui.fatal("Bad request (400): #{response['badRequest']['message']}")
    #         exit 1
    #       end
    #     else
    #       ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
    #       raise e
    #     end
    #   end

    #   msg_pair("Instance Name", server.name)
    #   msg_pair("Instance ID", server.id)

    #   print "\n#{ui.color("Waiting for server", :magenta)}"

    #   # wait for it to be ready to do stuff
    #   server.wait_for(Integer(locate_config_value(:server_create_timeout))) { print "."; ready? }

    #   puts("\n")

    #   msg_pair("Flavor", server.flavor['id'])
    #   msg_pair("Image", server.image['id'])
    #   msg_pair("SSH Identity File", config[:identity_file])
    #   msg_pair("SSH Keypair", server.key_name) if server.key_name
    #   msg_pair("SSH Password", server.password) if (server.password && !server.key_name)
    #   Chef::Log.debug("Addresses #{server.addresses}")
    #   msg_pair("Public IP Address", primary_public_ip_address(server.addresses)) if primary_public_ip_address(server.addresses)

    #   floating_address = locate_config_value(:floating_ip)
    #   Chef::Log.debug("Floating IP Address requested #{floating_address}")
    #   unless (floating_address == '-1') #no floating IP requested
    #     addresses = connection.addresses
    #     #floating requested without value
    #     if floating_address.nil?
    #       free_floating = addresses.find_index {|a| a.fixed_ip.nil?}
    #       if free_floating.nil? #no free floating IP found
    #         ui.error("Unable to assign a Floating IP from allocated IPs.")
    #         exit 1
    #       else
    #         floating_address = addresses[free_floating].ip
    #       end
    #     end
    #     server.associate_address(floating_address)
    #     #a bit of a hack, but server.reload takes a long time
    #     (server.addresses['public'] ||= []) << {"version"=>4,"addr"=>floating_address}
    #     msg_pair("Floating IP Address", floating_address)
    #   end

    #   Chef::Log.debug("Addresses #{server.addresses}")
    #   Chef::Log.debug("Public IP Address actual: #{primary_public_ip_address(server.addresses)}") if primary_public_ip_address(server.addresses)

    #   msg_pair("Private IP Address", primary_private_ip_address(server.addresses)) if primary_private_ip_address(server.addresses)

    #   #which IP address to bootstrap
    #   bootstrap_ip_address = primary_public_ip_address(server.addresses) if primary_public_ip_address(server.addresses)
    #   if config[:private_network]
    #     bootstrap_ip_address = primary_private_ip_address(server.addresses)
    #   end

    #   Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
    #   if bootstrap_ip_address.nil?
    #     ui.error("No IP address available for bootstrapping.")
    #     exit 1
    #   end

    #   if locate_config_value(:bootstrap_protocol) == 'winrm'
    #     print "\n#{ui.color("Waiting for winrm", :magenta)}"
    #     print(".") until tcp_test_winrm(bootstrap_ip_address, locate_config_value(:winrm_port))
    #     bootstrap_for_windows_node(server, bootstrap_ip_address).run
    #   else
    #     print "\n#{ui.color("Waiting for sshd", :magenta)}"
    #     print(".") until tcp_test_ssh(bootstrap_ip_address) {
    #       sleep @initial_sleep_delay ||= 10
    #       puts("done")
    #     }
    #     bootstrap_for_node(server, bootstrap_ip_address).run
    #   end
    #   puts "\n"
    #   msg_pair("Instance Name", server.name)
    #   msg_pair("Instance ID", server.id)
    #   msg_pair("Flavor", server.flavor['id'])
    #   msg_pair("Image", server.image['id'])
    #   msg_pair("SSH Keypair", server.key_name) if server.key_name
    #   msg_pair("SSH Password", server.password) if (server.password && !server.key_name)
    #   msg_pair("Public IP Address", primary_public_ip_address(server.addresses)) if primary_public_ip_address(server.addresses)
    #   msg_pair("Private IP Address", primary_private_ip_address(server.addresses)) if primary_private_ip_address(server.addresses)
    #   msg_pair("Environment", config[:environment] || '_default')
    #   msg_pair("Run List", config[:run_list].join(', '))
    # end

    # def bootstrap_for_windows_node(server, bootstrap_ip_address)
    #   bootstrap = Chef::Knife::BootstrapWindowsWinrm.new
    #   bootstrap.name_args = [bootstrap_ip_address]
    #   bootstrap.config[:winrm_user] = locate_config_value(:winrm_user) || 'Administrator'
    #   bootstrap.config[:winrm_password] = locate_config_value(:winrm_password)
    #   bootstrap.config[:winrm_transport] = locate_config_value(:winrm_transport)
    #   bootstrap.config[:winrm_port] = locate_config_value(:winrm_port)
    #   bootstrap_common_params(bootstrap, server.name)
    # end

    # def bootstrap_common_params(bootstrap, server_name)
    #   bootstrap.config[:chef_node_name] = config[:chef_node_name] || server_name
    #   bootstrap.config[:run_list] = config[:run_list]
    #   bootstrap.config[:prerelease] = config[:prerelease]
    #   bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
    #   bootstrap.config[:distro] = locate_config_value(:distro)
    #   bootstrap.config[:template_file] = locate_config_value(:template_file)
    #   bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
    #   bootstrap.config[:environment] = config[:environment]
    #   bootstrap.config[:encrypted_data_bag_secret] = config[:encrypted_data_bag_secret]
    #   bootstrap.config[:encrypted_data_bag_secret_file] = config[:encrypted_data_bag_secret_file]
    #   # let ohai know we're using OpenStack
    #   Chef::Config[:knife][:hints] ||= {}
    #   Chef::Config[:knife][:hints]['openstack'] ||= {}
    #   bootstrap
    # end

    # def bootstrap_for_node(server, bootstrap_ip_address)
    #   bootstrap = Chef::Knife::Bootstrap.new
    #   bootstrap.name_args = [bootstrap_ip_address]
    #   bootstrap.config[:ssh_user] = config[:ssh_user]
    #   bootstrap.config[:identity_file] = config[:identity_file]
    #   bootstrap.config[:host_key_verify] = config[:host_key_verify]
    #   bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
    #   bootstrap_common_params(bootstrap, server.name)
    # end

    # def flavor
    #   @flavor ||= connection.flavors.get(locate_config_value(:flavor))
    # end

    # def image
    #   @image ||= connection.images.get(locate_config_value(:image))
    # end

    # def is_floating_ip_valid
    #   address = locate_config_value(:floating_ip)
    #   if address == '-1' #no floating IP requested
    #     return true
    #   end
    #   addresses = connection.addresses
    #   return false if addresses.empty? #no floating IPs
    #   #floating requested without value
    #   if address.nil?
    #     if addresses.find_index {|a| a.fixed_ip.nil?}
    #       return true
    #     else
    #       return false #no floating IPs available
    #     end
    #   end
    #   #floating requested with value
    #   if addresses.find_index {|a| a.ip == address}
    #     return true
    #   else
    #     return false #requested floating IP does not exist
    #   end
    # end

    # def validate!
    #   super([:image, :openstack_username, :openstack_password, :openstack_auth_url])

    #   if flavor.nil?
    #     ui.error("You have not provided a valid flavor ID. Please note the options for this value are -f or --flavor.")
    #     exit 1
    #   end

    #   if image.nil?
    #     ui.error("You have not provided a valid image ID. Please note the options for this value are -I or --image.")
    #     exit 1
    #   end

    #   if !is_floating_ip_valid
    #     ui.error("You have either requested an invalid floating IP address or none are available.")
    #     exit 1
    #   end
    # end

    # #generate a random name if chef_node_name is empty
    # def get_node_name(chef_node_name)
    #   return chef_node_name unless chef_node_name.nil?
    #   #lazy uuids
    #   chef_node_name = "os-"+rand.to_s.split('.')[1]
    # end
    def run
        $stdout.sync = true

        @cloud_service = Cloud::OpenstackService.new(self)
        # @cloud_service.server_create()
    end
  end
end
end
