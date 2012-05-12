## v0.6.0
* Switched to OpenStack API from OpenStack EC2 API.
* Updated to point to master branch of Fog for latest `OpenStack` provider
* knife openstack server create (KNIFE_OPENSTACK-1)
* knife openstack server delete (KNIFE_OPENSTACK-2)
* Support for unenven_columns for prettier output (KNIFE_OPENSTACK-5)
* Added chef gem dependency (KNIFE_OPENSTACK-6)
* Added virtual cpus to 'knife openstack flavor list'
* Removed unsupported features to match current state of plugin (public_key, kernel, architecture, cores, location)

## v0.5.2
* initial Cactus release using EC2 API
