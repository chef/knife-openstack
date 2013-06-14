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
require 'chef/knife/winrm_base'

class Chef
  class Knife
    class OpenstackServerCreate < Knife

      include Knife::OpenstackBase
      include Chef::Knife::WinrmBase

      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end

      banner "knife openstack server create (options)"

      attr_accessor :initial_sleep_delay

      option :flavor,
      :short => "-f FLAVOR_ID",
      :long => "--flavor FLAVOR_ID",
      :description => "The flavor ID of server (m1.small, m1.medium, etc)",
      :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

      option :image,
      :short => "-I IMAGE_ID",
      :long => "--image IMAGE_ID",
      :description => "The image ID for the server",
      :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }

      option :security_groups,
      :short => "-G X,Y,Z",
      :long => "--groups X,Y,Z",
      :description => "The security groups for this server",
      :default => ["default"],
      :proc => Proc.new { |groups| groups.split(',') }

      option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The Chef node name for your new node"

      option :floating_ip,
      :short => "-a [IP]",
      :long => "--floating-ip [IP]",
      :default => "-1",
      :description => "Request to associate a floating IP address to the new OpenStack node. Assumes IPs have been allocated to the project. Specific IP is optional."

      option :private_network,
      :long => "--private-network",
      :description => "Use the private IP for bootstrapping rather than the public IP",
      :boolean => true,
      :default => false

      option :ssh_key_name,
      :short => "-S KEY",
      :long => "--ssh-key KEY",
      :description => "The OpenStack SSH keypair id",
      :proc => Proc.new { |key| Chef::Config[:knife][:openstack_ssh_key_id] = key }

      option :ssh_port,
      :short => "-p PORT",
      :long => "--ssh-port PORT",
      :description => "The ssh port",
      :default => "22",
      :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

      option :ssh_user,
      :short => "-x USERNAME",
      :long => "--ssh-user USERNAME",
      :description => "The ssh username",
      :default => "root"

      option :ssh_password,
      :short => "-P PASSWORD",
      :long => "--ssh-password PASSWORD",
      :description => "The ssh password"

      option :identity_file,
      :short => "-i IDENTITY_FILE",
      :long => "--identity-file IDENTITY_FILE",
      :description => "The SSH identity file used for authentication"

      option :prerelease,
      :long => "--prerelease",
      :description => "Install the pre-release chef gems"

      option :bootstrap_version,
      :long => "--bootstrap-version VERSION",
      :description => "The version of Chef to install",
      :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }

      option :distro,
      :short => "-d DISTRO",
      :long => "--distro DISTRO",
      :description => "Bootstrap a distro using a template; default is 'chef-full'",
      :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
      :default => "chef-full"

      option :template_file,
      :long => "--template-file TEMPLATE",
      :description => "Full path to location of template to use",
      :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
      :default => false

      option :run_list,
      :short => "-r RUN_LIST",
      :long => "--run-list RUN_LIST",
      :description => "Comma separated list of roles/recipes to apply",
      :proc => lambda { |o| o.split(/[\s,]+/) },
      :default => []

      option :host_key_verify,
      :long => "--[no-]host-key-verify",
      :description => "Verify host key, enabled by default",
      :boolean => true,
      :default => true

      option :bootstrap_protocol,
      :long => "--bootstrap-protocol protocol",
      :description => "Protocol to bootstrap Windows servers. options: winrm",
      :default => nil

      option :bootstrap_proxy,
      :long => "--bootstrap-proxy PROXY_URL",
      :description => "The proxy server for the node being bootstrapped",
      :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_proxy] = v }

      option :server_create_timeout,
      :long => "--server-create-timeout timeout",
      :description => "How long to wait until the server is ready; default is 600 seconds",
      :default => 600,
      :proc => Proc.new { |v| Chef::Config[:knife][:server_create_timeouts] = v}

      def tcp_test_ssh(hostname, port)
        tcp_socket = TCPSocket.new(hostname, port)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname} port #{port}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
        sleep 2
        false
      rescue Errno::ENETUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def tcp_test_winrm(hostname, port)
        TCPSocket.new(hostname, port)
        return true
      rescue SocketError
        sleep 2
        false
      rescue Errno::ETIMEDOUT
        false
      rescue Errno::EPERM
        false
      rescue Errno::ECONNREFUSED
        sleep 2
        false
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      rescue Errno::ENETUNREACH
        sleep 2
        false
      end

      def load_winrm_deps
        require 'winrm'
        require 'em-winrm'
        require 'chef/knife/bootstrap_windows_winrm'
        require 'chef/knife/core/windows_bootstrap_context'
        require 'chef/knife/winrm'
      end
      def run
        $stdout.sync = true

        validate!
        if locate_config_value(:bootstrap_protocol) == 'winrm'
          load_winrm_deps
        else
          # workaround for KNIFE-296 winrm values stomping on ssh values
          # unchanged ssh_user and changed winrm_user, override ssh_user
          if locate_config_value(:ssh_user).eql?(options[:ssh_user][:default]) &&
              !locate_config_value(:winrm_user).eql?(options[:winrm_user][:default])
            config[:ssh_user] = locate_config_value(:winrm_user)
          end
          # unchanged ssh_port and changed winrm_port, override ssh_port
          if locate_config_value(:ssh_port).eql?(options[:ssh_port][:default]) &&
              !locate_config_value(:winrm_port).eql?(options[:winrm_port][:default])
            config[:ssh_port] = locate_config_value(:winrm_port)
          end
          # unset ssh_password and set winrm_password, override ssh_password
          if locate_config_value(:ssh_password).nil? &&
              !locate_config_value(:winrm_password).nil?
            config[:ssh_password] = locate_config_value(:winrm_password)
          end
          # unset identity_file and set kerberos_keytab_file, override identity_file
          if locate_config_value(:identity_file).nil? &&
              !locate_config_value(:kerberos_keytab_file).nil?
            config[:identity_file] = locate_config_value(:kerberos_keytab_file)
          end
        end
        #servers require a name, generate one if not passed
        node_name = get_node_name(config[:chef_node_name])

        server_def = {
        :name => node_name,
        :image_ref => locate_config_value(:image),
        :flavor_ref => locate_config_value(:flavor),
        :security_groups => locate_config_value(:security_groups),
        :key_name => locate_config_value(:openstack_ssh_key_id)
      }

      Chef::Log.debug("Name #{node_name}")
      Chef::Log.debug("Image #{locate_config_value(:image)}")
      Chef::Log.debug("Flavor #{locate_config_value(:flavor)}")
      Chef::Log.debug("Requested Floating IP #{locate_config_value(:floating_ip)}")
      Chef::Log.debug("Security Groups #{locate_config_value(:security_groups)}")
      Chef::Log.debug("Creating server #{server_def}")

      begin
        server = connection.servers.create(server_def)
      rescue Excon::Errors::BadRequest => e
        response = Chef::JSONCompat.from_json(e.response.body)
        if response['badRequest']['code'] == 400
          if response['badRequest']['message'] =~ /Invalid flavorRef/
            ui.fatal("Bad request (400): Invalid flavor specified: #{server_def[:flavor_ref]}")
            exit 1
          else
            ui.fatal("Bad request (400): #{response['badRequest']['message']}")
            exit 1
          end
        else
          ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
          raise e
        end
      end

      msg_pair("Instance Name", server.name)
      msg_pair("Instance ID", server.id)

      print "\n#{ui.color("Waiting for server", :magenta)}"

      # wait for it to be ready to do stuff
      server.wait_for(Integer(locate_config_value(:server_create_timeout))) { print "."; ready? }

      puts("\n")

      msg_pair("Flavor", server.flavor['id'])
      msg_pair("Image", server.image['id'])
      msg_pair("SSH Identity File", config[:identity_file])
      msg_pair("SSH Keypair", server.key_name) if server.key_name
      msg_pair("SSH Password", server.password) if (server.password && !server.key_name)
      Chef::Log.debug("Addresses #{server.addresses}")
      msg_pair("Public IP Address", primary_public_ip_address(server.addresses)) if primary_public_ip_address(server.addresses)

      floating_address = locate_config_value(:floating_ip)
      Chef::Log.debug("Floating IP Address requested #{floating_address}")
      unless (floating_address == '-1') #no floating IP requested
        addresses = connection.addresses
        #floating requested without value
        if floating_address.nil?
          free_floating = addresses.find_index {|a| a.fixed_ip.nil?}
          if free_floating.nil? #no free floating IP found
            ui.error("Unable to assign a Floating IP from allocated IPs.")
            exit 1
          else
            floating_address = addresses[free_floating].ip
          end
        end
        server.associate_address(floating_address)
        #a bit of a hack, but server.reload takes a long time
        (server.addresses['public'] ||= []) << {"version"=>4,"addr"=>floating_address}
        msg_pair("Floating IP Address", floating_address)
      end

      Chef::Log.debug("Addresses #{server.addresses}")
      Chef::Log.debug("Public IP Address actual: #{primary_public_ip_address(server.addresses)}") if primary_public_ip_address(server.addresses)

      msg_pair("Private IP Address", primary_private_ip_address(server.addresses)) if primary_private_ip_address(server.addresses)

      #which IP address to bootstrap
      bootstrap_ip_address = primary_public_ip_address(server.addresses) if primary_public_ip_address(server.addresses)
      if config[:private_network]
        bootstrap_ip_address = primary_private_ip_address(server.addresses)
      end

      Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
      if bootstrap_ip_address.nil?
        ui.error("No IP address available for bootstrapping.")
        exit 1
      end

      if locate_config_value(:bootstrap_protocol) == 'winrm'
        print "\n#{ui.color("Waiting for winrm", :magenta)}"
        print(".") until tcp_test_winrm(bootstrap_ip_address, locate_config_value(:winrm_port))
        bootstrap_for_windows_node(server, bootstrap_ip_address).run
      else
        Chef::Log.debug("Waiting for sshd on IP address: #{bootstrap_ip_address} and port: #{locate_config_value(:ssh_port)}")
        print "\n#{ui.color("Waiting for sshd", :magenta)}"
        print(".") until tcp_test_ssh(bootstrap_ip_address, locate_config_value(:ssh_port)) {
          sleep @initial_sleep_delay ||= 10
          puts("done")
        }
        bootstrap_for_node(server, bootstrap_ip_address).run
      end
      puts "\n"
      msg_pair("Instance Name", server.name)
      msg_pair("Instance ID", server.id)
      msg_pair("Flavor", server.flavor['id'])
      msg_pair("Image", server.image['id'])
      msg_pair("SSH Keypair", server.key_name) if server.key_name
      msg_pair("SSH Password", server.password) if (server.password && !server.key_name)
      msg_pair("Public IP Address", primary_public_ip_address(server.addresses)) if primary_public_ip_address(server.addresses)
      msg_pair("Private IP Address", primary_private_ip_address(server.addresses)) if primary_private_ip_address(server.addresses)
      msg_pair("Environment", config[:environment] || '_default')
      msg_pair("Run List", config[:run_list].join(', '))
    end

    def bootstrap_for_windows_node(server, bootstrap_ip_address)
      bootstrap = Chef::Knife::BootstrapWindowsWinrm.new
      bootstrap.name_args = [bootstrap_ip_address]
      bootstrap.config[:winrm_user] = locate_config_value(:winrm_user) || 'Administrator'
      bootstrap.config[:winrm_password] = locate_config_value(:winrm_password)
      bootstrap.config[:winrm_transport] = locate_config_value(:winrm_transport)
      bootstrap.config[:winrm_port] = locate_config_value(:winrm_port)
      bootstrap_common_params(bootstrap, server.name)
    end

    def bootstrap_common_params(bootstrap, server_name)
      bootstrap.config[:chef_node_name] = config[:chef_node_name] || server_name
      bootstrap.config[:run_list] = config[:run_list]
      bootstrap.config[:prerelease] = config[:prerelease]
      bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
      bootstrap.config[:distro] = locate_config_value(:distro)
      bootstrap.config[:template_file] = locate_config_value(:template_file)
      bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
      bootstrap.config[:environment] = config[:environment]
      bootstrap.config[:encrypted_data_bag_secret] = config[:encrypted_data_bag_secret]
      bootstrap.config[:encrypted_data_bag_secret_file] = config[:encrypted_data_bag_secret_file]
      # let ohai know we're using OpenStack
      Chef::Config[:knife][:hints] ||= {}
      Chef::Config[:knife][:hints]['openstack'] ||= {}
      bootstrap
    end

    def bootstrap_for_node(server, bootstrap_ip_address)
      bootstrap = Chef::Knife::Bootstrap.new
      bootstrap.name_args = [bootstrap_ip_address]
      bootstrap.config[:ssh_user] = config[:ssh_user]
      bootstrap.config[:ssh_port] = config[:ssh_port]
      bootstrap.config[:identity_file] = config[:identity_file]
      bootstrap.config[:host_key_verify] = config[:host_key_verify]
      bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
      bootstrap_common_params(bootstrap, server.name)
    end

    def flavor
      @flavor ||= connection.flavors.get(locate_config_value(:flavor))
    end

    def image
      @image ||= connection.images.get(locate_config_value(:image))
    end

    def is_floating_ip_valid
      address = locate_config_value(:floating_ip)
      if address == '-1' #no floating IP requested
        return true
      end
      addresses = connection.addresses
      return false if addresses.empty? #no floating IPs
      #floating requested without value
      if address.nil?
        if addresses.find_index {|a| a.fixed_ip.nil?}
          return true
        else
          return false #no floating IPs available
        end
      end
      #floating requested with value
      if addresses.find_index {|a| a.ip == address}
        return true
      else
        return false #requested floating IP does not exist
      end
    end

    def validate!
      super([:image, :openstack_username, :openstack_password, :openstack_auth_url])

      if flavor.nil?
        ui.error("You have not provided a valid flavor ID. Please note the options for this value are -f or --flavor.")
        exit 1
      end

      if image.nil?
        ui.error("You have not provided a valid image ID. Please note the options for this value are -I or --image.")
        exit 1
      end

      if !is_floating_ip_valid
        ui.error("You have either requested an invalid floating IP address or none are available.")
        exit 1
      end
    end

    #generate a random name if chef_node_name is empty
    def get_node_name(chef_node_name)
      return chef_node_name unless chef_node_name.nil?
      #lazy uuids
      chef_node_name = "os-"+rand.to_s.split('.')[1]
    end
  end
end
end
