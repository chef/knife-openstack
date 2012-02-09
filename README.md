Knife OpenStack
===============

This is the official Opscode Knife plugin for OpenStack Compute (Nova). This plugin gives knife the ability to create, bootstrap, and manage instances in OpenStack Compute clouds.

# Installation #

Be sure you are running the latest version Chef. Versions earlier than 0.10.0 don't support plugins:

    $ gem install chef

This plugin is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-openstack

Depending on your system's configuration, you may need to run this command with root privileges.

# Configuration #

In order to communicate with an OpenStack Compute cloud's EC2 API you will have to tell Knife about your OpenStack Compute cloud API endpoint, OpenStack Access Key and Secret Access Key. The easiest way to accomplish this is to create some entries in your `knife.rb` file:

    ### Note: You may need to append the :openstack_access_key_id with ":$PROJECT_NAME", if it differs from your OpenStack Username.
    knife[:openstack_access_key_id]     = "Your OpenStack Access Key ID"
    knife[:openstack_secret_access_key] = "Your OpenStack Secret Access Key"
    ### Note: If you are not proxying HTTPS to the OpenStack EC2 API port, the scheme should be HTTP, and the PORT is 8773.
    knife[:openstack_api_endpoint]      = "https://cloud.mycompany.com/service/Cloud"

If your knife.rb file will be checked into a SCM system (ie readable by others) you may want to read the values from environment variables:

    knife[:openstack_access_key_id]     = "#{ENV['EC2_ACCESS_KEY']}"
    knife[:openstack_secret_access_key] = "#{ENV['EC2_SECRET_KEY']}"
    knife[:openstack_api_endpoint]      = "#{ENV['EC2_URL']}"

You also have the option of passing your OpenStack API Key/Secret into the individual knife subcommands using the `-A` (or `--openstack-access-key-id`) `-K` (or `--openstack-secret-access-key`) command options

    # provision a new m1.small Ubuntu 10.04 webserver
    knife openstack server create 'role[webserver]' -I ami-7000f019 -f m1.small -A 'Your OpenStack Access Key ID' -K 'Your OpenStack Secret Access Key' --openstack-api-endpoint 'https://cloud.mycompany.com/v1.0'

Additionally the following options may be set in your `knife.rb`:

* flavor
* image
* availability_zone
* openstack_ssh_key_id
* region
* distro
* template_file

# Subcommands #

This plugin provides the following Knife subcommands. Specific command options can be found by invoking the subcommand with a `--help` flag

knife openstack server create
-----------------------------

Provisions a new server in an OpenStack Compute cloud and then perform a Chef bootstrap (using the SSH protocol). The goal of the bootstrap is to get Chef installed on the target system so it can run Chef Client with a Chef Server. The main assumption is a baseline OS installation exists (provided by the provisioning). It is primarily intended for Chef Client systems that talk to a Chef server. By default the server is bootstrapped using the [ubuntu10.04-gems](https://github.com/opscode/chef/blob/master/chef/lib/chef/knife/bootstrap/ubuntu10.04-gems.erb) template. This can be overridden using the `-d` or `--template-file` command options.

knife openstack server delete
-----------------------------

Deletes an existing server in the currently configured OpenStack Compute cloud account. <b>PLEASE NOTE</b> - this does not delete the associated node and client objects from the Chef server.

knife openstack server list
---------------------------

Outputs a list of all servers in the currently configured OpenStack Compute cloud account. <b>PLEASE NOTE</b> - this shows all instances associated with the account, some of which may not be currently managed by the Chef server.

knife openstack flavor list
---------------------------

Outputs a list of all available flavors (available hardware configuration for a server) available to the currently configured OpenStack Compute cloud account. Each flavor has a unique combination of disk space, memory capacity and priority for CPU time. This data can be useful when choosing a flavor id to pass to the `knife openstack server create` subcommand.

knife openstack image list
--------------------------

Outputs a list of all available images available to the currently configured OpenStack Compute cloud account. An image is a collection of files used to create or rebuild a server. This data can be useful when choosing an image id to pass to the `knife openstack server create` subcommand.

# License #

Author:: Seth Chisamore (<schisamo@opscode.com>)

Author:: Matt Ray (<matt@opscode.com>)

Copyright:: Copyright (c) 2011-2012 Opscode, Inc.

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
