[![Build Status](https://travis-ci.org/chef/knife-openstack.png)](https://travis-ci.org/chef/knife-openstack)

Knife OpenStack
===============

This is the official Chef Knife plugin for OpenStack Compute (Nova). This plugin gives knife the ability to create, bootstrap and manage instances in OpenStack Compute clouds. It has been tested against the `Diablo` through `Icehouse` releases in configurations using Keystone against the OpenStack API (as opposed to the EC2 API).

Please refer to the [CHANGELOG](CHANGELOG.md) for version history and known issues.

# Installation #

Be sure you are running the latest version Chef. Versions earlier than 0.10.0 don't support plugins:

    $ gem install chef

This plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-openstack

Depending on your system's configuration, you may need to run this command with root privileges.

# Configuration #

In order to communicate with an OpenStack API you will need to tell Knife your OpenStack Auth API endpoint, your Dashboard username and password (tenant is optional). The easiest way to accomplish this is to create these entries in your `knife.rb` file:

    ### Note: If you are not proxying HTTPS to the OpenStack auth port, the scheme should be HTTP
    knife[:openstack_auth_url] = "http://cloud.mycompany.com:5000/v2.0/tokens"
    knife[:openstack_username] = "Your OpenStack Dashboard username"
    knife[:openstack_password] = "Your OpenStack Dashboard password"
    knife[:openstack_tenant] = "Your OpenStack tenant name"

If your knife.rb file will be checked into a SCM system (ie readable by others) you may want to read the values from environment variables.  For example, using the conventions of [OpenStack's RC file](http://docs.openstack.org/user-guide/content/cli_openrc.html) (note the `openstack_auth_url`):

    knife[:openstack_auth_url] = "#{ENV['OS_AUTH_URL']}/tokens"
    knife[:openstack_username] = "#{ENV['OS_USERNAME']}"
    knife[:openstack_password] = "#{ENV['OS_PASSWORD']}"
    knife[:openstack_tenant] = "#{ENV['OS_TENANT_NAME']}"

If your OpenStack deployment is over SSL, but does not have a valid certificate, you can add the following option to bypass SSL check:

    knife[:openstack_insecure] = true

If you need to use alternate service endpoints for communicating with OpenStack, you can set the following option:

    knife[:openstack_endpoint_type] = "internalURL"

You also have the option of passing your OpenStack API Username/Password into the individual knife subcommands using the `-A` (or `--openstack-username`) `-K` (or `--openstack-password`) command options

    # provision a new image named kb01
    knife openstack server create -A 'MyUsername' -K 'MyPassword' --openstack-api-endpoint 'http://cloud.mycompany.com:5000/v2.0/tokens' -f 1 -I 13 -S trystack -i ~/.ssh/trystack.pem -r 'role[webserver]'

Additionally the following options may be set in your `knife.rb`:

* flavor
* image
* openstack_ssh_key_id
* template_file

# Working with Floating IPs #

To use a floating IP address while bootstrapping nodes, use the `-a` or `--openstack-floating-ip` option.

# Working with Windows Images #

Provisioning and bootstrapping for Windows 2003 and later images is now supported. The Windows images need to have WinRM enabled with Basic Authentication configured. Current support does not support Kerberos Authentication.

Example:

    knife openstack server create -I <Image> -f <Flavor> -S <keypair_name> --bootstrap-protocol winrm -P <Administrator_Password> -x Administrator -N <chef_node_name> --template windows-chef-client-msi.erb

NOTE:
* Bootstrap Protocol (`--bootstrap-protocol`) is required to be set to `winrm`.
* Administrator Username (`--winrm-user` or `-x`) and Password (`-P`) are required parameters.
* If the Template File (`--template`) is not specified it defaults to a Linux distro (most likely Ubuntu).

# Subcommands #

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` option.

knife openstack server create
-----------------------------

Provisions a new server in an OpenStack Compute cloud and then perform a Chef bootstrap (using the SSH protocol). The goal of the bootstrap is to get Chef installed on the target system so it can run Chef Client with a Chef Server. The main assumption is a baseline OS installation exists (provided by the provisioning). It is primarily intended for Chef Client systems that talk to a Chef server. By default the server is bootstrapped using the [chef-full](https://github.com/opscode/chef/blob/master/chef/lib/chef/knife/bootstrap/chef-full.erb) template (default since the 10.10 release). This may be overridden using the `-d` or `--template-file` command options. If you do not have public IP addresses, use the `--private-network` option to use the private IP address for bootstrapping or `--bootstrap-network NAME` to specify an alternate network. Please see `knife openstack server create --help` for all of the supported options.

knife openstack server delete
-----------------------------

Deletes an existing server in the currently configured OpenStack account. If a floating IP address has been assigned to the node, it is disassociated automatically by the OpenStack server. <b>PLEASE NOTE</b> - this does not delete the associated node and client objects from the Chef server without using the `-P` option to purge the client.

knife openstack server list
---------------------------

Outputs a list of all servers in the currently configured OpenStack account. <b>PLEASE NOTE</b> - this shows all instances associated with the account, some of which may not be currently managed by the Chef server.

knife openstack flavor list
---------------------------

Provides a list of all available flavors (available "hardware" configurations for a server) available to the currently configured OpenStack account. Each flavor has a unique combination of virtual cpus, disk space and memory capacity. This data may be useful when choosing a flavor to pass to the `knife openstack server create` subcommand.

knife openstack image list
--------------------------

Lists all available images and snapshots available to the currently configured OpenStack account. An image is a collection of files used to create or rebuild a server. The retuned list filters out image names ending in 'initrd', 'kernel', 'loader', 'virtual' or 'vmlinuz' (this may be disabled with `--disable-filter`). This data may be useful when choosing an image to pass to the `knife openstack server create` subcommand.

knife openstack group list
--------------------

Provides a list of the security groups available to the currently configured OpenStack account. Each group may have multiple rules. This data may be useful when choosing your security group(s) to pass to the `knife openstack server create` subcommand.

knife openstack network list
--------------------

Lists the networks available to the currently configured OpenStack account. This data may be useful when choosing your networks to pass to the `knife openstack server create` subcommand. This command is only available with OpenStack deployments using the Neutron network service (not nova-network). Please see `knife openstack server create --help` for all of the supported options.

# License #

Author:: Seth Chisamore (<schisamo@getchef.com>)

Author:: Matt Ray (<matt@getchef.com>)

Author:: Chirag Jog (<chirag@clogeny.com>)

Copyright:: Copyright (c) 2011-2014 Chef Software, Inc.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
