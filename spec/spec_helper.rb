$:.unshift File.expand_path('../../lib', __FILE__)

require 'chef/knife/bootstrap'
require 'chef/knife/openstack_helpers'
require 'fog'
