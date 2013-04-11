## v0.7.1

* file permissions fixed (KNIFE-261)

## v0.7.0
* Update dependency on to Fog 1.10.0
* 'delay-loading' changes to reduce load-time (Mohit Sethi)
* Use the hint with the bootstrap method instead of assuming the :personality works with the server.create method (KNIFE-201)
* Added 'knife openstack group list' for listing security groups and their rules (KNIFE-227)
* Filter out extraneous images from knife openstack image list and added '--disable-filter' to disable
* Fixed minor issue for public ip addresses (Edmund Haselwanter)
* Fixed security groups, adding `-G` support (KNIFE-230)
* Added snapshots as a new column in image list
* "knife openstack image list" fails with empty image name (KNIFE-83)(Simon Belluzzo)
* excon / fog errors are a JSON blob, Rescue fog errors (KNIFE-87)(Bryan McLellan)
* Better error handling for connection errors.
* Pass ssh_password to bootstrap (KNIFE-88)(David Petzel)
* Catch Net Unreachable error (E.J. Finneran)
* Allow an option to ignore the SSL cert (KNIFE-225)(BK Box)
* Attach to floating IPs (Mohit Sethi)
* Key pair is not required (KNIFE-226)(BK Box)
* Fog 1.10.0 changes API for OpenStack IP addresses (KNIFE-248)

## v0.6.2
* Use less pessimistic fog version constraint.
* Add guards to protect against nil values for private_ip_address

## v0.6.0
* Switched to OpenStack API from OpenStack EC2 API.
* Updated to point to Fog 1.4.0 for latest `OpenStack` provider
* testing with Diablo & Essex
* knife openstack server create (KNIFE_OPENSTACK-1)
* knife openstack server delete (KNIFE_OPENSTACK-2)
* Support for unenven_columns for prettier output (KNIFE_OPENSTACK-5)
* Added chef gem dependency (KNIFE_OPENSTACK-6)
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
* Windows bootstrapping (winrm-based) support for knife-openstack (KNIFE-221) winrm branch, UGLY WARNINGS NEED RESOLUTION
* purge only works when names match up with clients
* `knife openstack floating list|associate|release NODE` with --floating-ip-pool also
* Allow specifying the name of the pool when using floating IPs (KNIFE-229)
* attempt to allocate a floating ipaddress if none if free, currently missing in Fog
* take either the flavor ID or the flavor name (KNIFE-76)
* take either the image ID or the image name (similar for KNIFE-76)
* server create with expired password hangs (KNIFE-86)
* added ability to specify arbitrary network ID (KNIFE-231)
* assumption of only single floating IP (and fog uses the last as the public_ip_address)
* probably other places public network is assumed that could cause issues
* fog is putting the original public IP address into the private_ip_address method when you get a floating_ip, this is wrong. Remove KNIFE-248 code once fixed.
