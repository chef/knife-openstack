#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Author:: Matt Ray (<matt@opscode.com>)
# Copyright:: Copyright (c) 2011-2012 Opscode, Inc.
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

class Chef
  class Knife
    class OpenstackServerCreate < Knife

      include Knife::OpenstackBase

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

      # option :security_groups,
      # :short => "-G X,Y,Z",
      # :long => "--groups X,Y,Z",
      # :description => "The security groups for this server",
      # :default => ["default"],
      # :proc => Proc.new { |groups| groups.split(',') }

      option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The Chef node name for your new node"

      option :ssh_key_name,
      :short => "-S KEY",
      :long => "--ssh-key KEY",
      :description => "The OpenStack SSH keypair id",
      :proc => Proc.new { |key| Chef::Config[:knife][:openstack_ssh_key_id] = key }

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

      # option :no_host_key_verify,
      #   :long => "--no-host-key-verify",
      #   :description => "Disable host key verification",
      #   :boolean => true,
      #   :default => false

      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
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
      rescue Errno::EHOSTUNREACH
        sleep 2
        false
      ensure
        tcp_socket && tcp_socket.close
      end

      def run
        $stdout.sync = true

        validate!

        Chef::Log.debug("openstack_username #{Chef::Config[:knife][:openstack_username]}")
        Chef::Log.debug("openstack_auth_url #{Chef::Config[:knife][:openstack_auth_url]}")
        Chef::Log.debug("openstack_tenant #{Chef::Config[:knife][:openstack_tenant]}")

        connection = Fog::Compute.new(
          :provider => 'OpenStack',
          :openstack_username => Chef::Config[:knife][:openstack_username],
          :openstack_api_key => Chef::Config[:knife][:openstack_password],
          :openstack_auth_url => Chef::Config[:knife][:openstack_auth_url],
          :openstack_tenant => Chef::Config[:knife][:openstack_tenant]
          )

        server_def = {
        :name => config[:chef_node_name],
        :image_ref => locate_config_value(:image),
        :flavor_ref => locate_config_value(:flavor),
        #:groups => config[:security_groups],
        :key_name => Chef::Config[:knife][:openstack_ssh_key_id]
      }

      Chef::Log.debug("Name #{config[:chef_node_name]}")
      Chef::Log.debug("Image #{locate_config_value(:image)}")
      Chef::Log.debug("Flavor #{locate_config_value(:flavor)}")
      #Chef::Log.debug("Groups #{config[:security_groups]}")
      Chef::Log.debug("Creating server #{server_def}")
      server = connection.servers.create(server_def)

      msg_pair("Instance ID", server.id)
      msg_pair("Instance Name", server.name)
      #msg_pair("Security Groups", server.groups.join(", "))
      msg_pair("SSH Keypair", server.key_name)

      print "\n#{ui.color("Waiting for server", :magenta)}"

      # wait for it to be ready to do stuff
      server.wait_for { print "."; ready? }

      puts("\n")

      msg_pair("Flavor", server.flavor['id'])
      msg_pair("Image", server.image['id'])
      msg_pair("Public IP Address", server.public_ip_address['addr'])
      msg_pair("Private IP Address", server.private_ip_address['addr'])

      print "\n#{ui.color("Waiting for sshd", :magenta)}"

      print(".") until tcp_test_ssh(server.public_ip_address['addr']) {
        sleep @initial_sleep_delay ||= 10
        puts("done")
      }

      bootstrap_for_node(server).run

      puts "\n"
      msg_pair("Instance ID", server.id)
      msg_pair("Instance Name", server.name)
      msg_pair("Flavor", server.flavor['id'])
      msg_pair("Image", server.image['id'])
      #msg_pair("Security Groups", server.groups.join(", "))
      msg_pair("SSH Keypair", server.key_name)
      msg_pair("Public IP Address", server.public_ip_address['addr'])
      msg_pair("Private IP Address", server.private_ip_address['addr'])
      msg_pair("Environment", config[:environment] || '_default')
      msg_pair("Run List", config[:run_list].join(', '))
    end

    def bootstrap_for_node(server)
      bootstrap = Chef::Knife::Bootstrap.new
      bootstrap.name_args = [server.public_ip_address['addr']]
      bootstrap.config[:run_list] = config[:run_list]
      bootstrap.config[:ssh_user] = config[:ssh_user]
      bootstrap.config[:identity_file] = config[:identity_file]
      bootstrap.config[:chef_node_name] = config[:chef_node_name] || server.id
      bootstrap.config[:prerelease] = config[:prerelease]
      bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
      bootstrap.config[:distro] = locate_config_value(:distro)
      bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
      bootstrap.config[:template_file] = locate_config_value(:template_file)
      bootstrap.config[:environment] = config[:environment]
      # may be needed for vpc_mode
      #bootstrap.config[:no_host_key_verify] = config[:no_host_key_verify]
      bootstrap
    end

    def ami
      @ami ||= connection.images.get(locate_config_value(:image))
    end

    def validate!

      super([:image, :openstack_ssh_key_id, :openstack_username, :openstack_password, :openstack_auth_url])

      if ami.nil?
        ui.error("You have not provided a valid image ID. Please note the short option for this value recently changed from '-i' to '-I'.")
        exit 1
      end
    end

  end
end
end
