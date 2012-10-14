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
This is a list of features currently lacking and (eventually) under development:

* security groups are still broken, appear to be broken in Fog. Add `-G` support for security groups other than 'default'
* purge only works when names match up with clients
* `knife openstack floating list|associate|disassociate ip|node`
* take either the flavor ID or the flavor name
* take either the image ID or the image name
* more information in `knife openstack image list`
* get DNS names working
* availability zones
* filter out the *-initrd and *-kernel from 'openstack image list'. Fog -> container_format={aki|ari} or disk_format on the same params
* assumption of only single floating IP (and fog uses the last as the public_ip_address)
* probably other places public network is assumed that could cause issues
