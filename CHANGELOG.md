## v0.7.0
* Update dependency on to Fog 1.9.X
* 'delay-loading' changes to reduce load-time (Mohit Sethi)
* Use the hint with the bootstrap method instead of assuming the :personality works with the server.create method (KNIFE-201)
* Added 'knife openstack group list' for listing security groups and their rules (KNIFE-227)
* Filter out extraneous images from knife openstack image list and added '--disable-filter' to disable
* Fixed minor issue for public ip addresses (Edmund Haselwanter)
* Fixed security groups, adding `-G` support

TODO:
* snapshots get a new column in image list
* Guard against NoMethodError for image.name in image list (Simon Belluzzo) "knife openstack image list" fails with empty image name (KNIFE-83)
* server create with expired password hangs (KNIFE-86)
* excon / fog errors are a JSON blob, Rescue fog errors (KNIFE-87) (Bryan McLellan)
* Pass ssh_password to bootstrap (David Petzel) knife openstack server create doesn't pass along SSH Password (KNIFE-88)
* Attach to floating IPs (Mohit Sethi)
* Allow an option to ignore the SSL cert (KNIFE-225
* Key pair is not required (KNIFE-226
* Catch Net Unreachable error (E.J. Finneran)
* Basic availability zones support (Jarek Zmudzinski)
* Chef Environment config for bootstrapped nodes (Jarek Zmudzinski)
* knife openstack server delete fails on folsom (KNIFE-79)
* Syntax error fix during stale hostname check (anark, waiting on CLA)

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

## v0.5.2
* initial Cactus release using EC2 API

# BACKLOG/ISSUES #
This is a list of missing(?) features and open questions currently under development consideration:

* purge only works when names match up with clients
* `knife openstack floating list|associate|release NODE` with --floating-ip-pool also
* take either the flavor ID or the flavor name (KNIFE-76)
* take either the image ID or the image name (similar for KNIFE-76)
* assumption of only single floating IP (and fog uses the last as the public_ip_address)
* probably other places public network is assumed that could cause issues
* Windows bootstrapping (winrm-based) support for knife-openstack (KNIFE-221)
* should snapshots show up in knife openstack image list? or should there be knife openstack snapshot list?
