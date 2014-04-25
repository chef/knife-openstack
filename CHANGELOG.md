## v0.10.0
* KNIFE-368 Ability to specify metadata during OpenStack server create
* KNIFE-423 Add ability for knife-openstack to specify network IDs to attach
* KNIFE-428 Added Availability zone to knife openstack
* KNIFE-467 --no-network fails to find first network IP address
* KNIFE-474 knife openstack group list throws a fog deprecation warning

## v0.9.1
* KNIFE-462 missing user_data throws stack

## v0.9.0
* KNIFE-231 added ability to specify arbitrary bootstrap network ID
* KNIFE-264 Add support for --json-attributes
* KNIFE-277 knife openstack "ERROR: No IP address available for bootstrapping."
* KNIFE-310 "knife openstack server list" will fail with boot from volume instances
* KNIFE-435 Support user data for OpenStack server create
* KNIFE-436 Support fixed network type for OpenStack server create
* https://github.com/opscode/chef-rfc/pull/7/ create/delete enhancements

## v0.8.1
* KNIFE-296 knife-windows overrides -i, -p, -P and -x options with winrm values
* KNIFE-304 enable setting the ssh port for knife-openstack

## v0.8.0
* KNIFE-221 Windows bootstrapping (winrm-based) support for knife-openstack (Chirag Jog)

## v0.7.1
* KNIFE-261 file permissions fixed

## v0.7.0
* Update dependency on to Fog 1.10.0
* 'delay-loading' changes to reduce load-time (Mohit Sethi)
* KNIFE-201 Use the hint with the bootstrap method instead of assuming the :personality works with the server.create method
* KNIFE-227 Added 'knife openstack group list' for listing security groups and their rules
* Filter out extraneous images from knife openstack image list and added '--disable-filter' to disable
* Fixed minor issue for public ip addresses (Edmund Haselwanter)
* KNIFE-230 Fixed security groups, adding `-G` support
* Added snapshots as a new column in image list
* KNIFE-83 "knife openstack image list" fails with empty image name (Simon Belluzzo)
* KNIFE-87 excon / fog errors are a JSON blob, Rescue fog errors (Bryan McLellan)
* Better error handling for connection errors.
* KNIFE-88 Pass ssh_password to bootstrap (David Petzel)
* Catch Net Unreachable error (E.J. Finneran)
* KNIFE-225 Allow an option to ignore the SSL cert (BK Box)
* Attach to floating IPs (Mohit Sethi)
* KNIFE-226 Key pair is not required (BK Box)
* KNIFE-248 Fog 1.10.0 changes API for OpenStack IP addresses

## v0.6.2
* Use less pessimistic fog version constraint.
* Add guards to protect against nil values for private_ip_address

## v0.6.0
* Switched to OpenStack API from OpenStack EC2 API.
* Updated to point to Fog 1.4.0 for latest `OpenStack` provider
* testing with Diablo & Essex
* KNIFE_OPENSTACK-1 knife openstack server create
* KNIFE_OPENSTACK-2 knife openstack server delete
* KNIFE_OPENSTACK-5 Support for unenven_columns for prettier output
* KNIFE_OPENSTACK-6 Added chef gem dependency
* Added virtual cpus to 'knife openstack flavor list'
* Removed unsupported features to match current state of plugin (public_key, kernel, architecture, cores, location)
* Added support for openstack_tenant (Rob Hirschfeld & Alexander Gordeev)
* Server list supports many more states
* Added support for associating floating IPs on server create and verified they are automatically disassociated on server delete
* Added /etc/chef/ohai/hints/openstack.json, the `openstack` Ohai plugin keys off of it and pulls from the meta-data service.
* Automated naming of nodes if `--node-name` is not passed
* Added support for `--no-host-key-verify` (Lamont Granquist)
* Added support for `--private-network` for bootstrapping private network

## V0.5.2
* initial Cactus release using EC2 API

# BACKLOG/ISSUES #
This is a list of missing(?) features and open questions currently under development consideration:

* Basic availability zones support (Jarek Zmudzinski) NEED TESTING ACCESS FOR AVAILABILITY ZONES
* purge only works when names match up with clients
* `knife openstack floating list|associate|release NODE` with --floating-ip-pool also
* KNIFE-229 Allow specifying the name of the pool when using floating IPs
* attempt to allocate a floating ipaddress if none if free, currently missing in Fog
* KNIFE-76 take either the flavor ID or the flavor name
* take either the image ID or the image name (similar for KNIFE-76)
* KNIFE-86 server create with expired password hangs
* KNIFE-231 added ability to specify arbitrary network ID
* assumption of only single floating IP (and fog uses the last as the public_ip_address)
* probably other places public network is assumed that could cause issues
* fog is putting the original public IP address into the private_ip_address method when you get a floating_ip, this is wrong. Remove KNIFE-248 code once fixed.
